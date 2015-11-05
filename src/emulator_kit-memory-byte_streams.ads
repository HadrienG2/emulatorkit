-- Copyright 2015 Hadrien Grasland
--
-- This file is part of EmulatorKit.
--
-- EmulatorKit is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- EmulatorKit is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with EmulatorKit.  If not, see <http://www.gnu.org/licenses/>.

with Ada.Exceptions;
with Emulator_Kit.Memory.Byte_Buffers;
--  with Emulator_Kit.Tasking;
with Emulator_Kit.Tasking.Shared_Resources;

-- This package defines a way to asynchronously transmit a stream of data between processes
package Emulator_Kit.Memory.Byte_Streams is

   -- This exception will be raised if a client attempts to access a stream beyond its bounds
   Reached_Stream_End : exception;

   -- Next, let's define a few shortcuts to make code more readable
   subtype Byte_Buffer is Byte_Buffers.Byte_Buffer;
   subtype Byte_Buffer_Index is Byte_Buffers.Byte_Buffer_Index;
   subtype Byte_Buffer_Size is Byte_Buffers.Byte_Buffer_Size;

   -- We'll also define a number of service requests that stream handlers should be able to process
   type Stream_Request is (Seek, Stop);
   type Stream_Request_Status is array (Stream_Request) of Boolean;

   -- This abstraction implements a stream of bytes, running through memory like a Unix file until it reaches the end of memory or is stopped by the client.
   --
   -- Chunk_Size is the size in bytes of the data chunks that will be written or read. It should be a divisor to the size of the accessed memory region.
   -- Larger chunk sizes reduce the client/server synchronization and memory transfer overhead, they should thus be preferred when they are practical.
   --
   -- Buffer_Size is the size of the stream's internal ring buffer. It should be chosen as a multiple of Chunk_Size. For a synchronous client that continuously
   -- listens to the server, 2x is good enough. But for less favorable client access patterns, such as doing nothing for a while, then asking for a lot
   -- of chunks at once, larger buffers may help performance.
--     protected type Byte_Stream (Buffer_Size : Byte_Buffer_Size; Chunk_Size : Byte_Buffer_Size) is new Tasking.Synchronous_Exception_Channel with  -- DEBUG : This should work, but doesn't on GNAT GPL 2015
   protected type Byte_Stream (Buffer_Size : Byte_Buffer_Size; Chunk_Size : Byte_Buffer_Size) is  -- DEBUG : This works

      -- Common interface for everyone involved
      procedure Invalidate_Buffer;

      -- Data sender interface
      function Available_Storage return Byte_Buffer_Size;
      entry Write_Data_Chunk (Input : Byte_Buffer; Input_Index : Byte_Buffer_Index);

      -- Data recipient interface
      function Available_Data return Byte_Buffer_Size;
      entry Read_Data_Chunk (Output : out Byte_Buffer; Output_Index : Byte_Buffer_Index);

      -- Client interface
      --   * Exceptions
      function Exception_Pending return Boolean;
      procedure Fetch_Exception with No_Return;
      --   * Stream end
      procedure Request_Stop;
      function At_End return Boolean;  -- NOTE : Do not count on this to prevent Read/Write procedures from raising an exception...
      --   * Stream seek
      entry Request_Seek (Destination : Universal_Address);

      -- Server interface
      --   * Exceptions
      entry Notify_Exception (Server_Exception : Ada.Exceptions.Exception_Occurrence);
      --   * General client request processing
      function Request_Pending return Boolean;
      entry Wait_For_Request (Request : out Stream_Request);
      --   * Stream end
      function Stop_Requested return Boolean;
      procedure Notify_Stream_End;
      --   * Stream seek
      function Seek_Requested return Boolean;
      function Seek_Address return Universal_Address;
      procedure Notify_Seek_Completion;

      -- These state-probing functions are intended to help with testing, and not meant to be used directly
      function Clients_Waiting_For_Seek return Natural;
      function Servers_Waiting_For_Exception_Fetch return Natural;
   private
      -- Stream data is stored in a ring buffer
      Ring_Buffer : Byte_Buffer (0 .. Buffer_Size); -- Allocate one extra byte, which will not be used, to disambiguate full and empty buffers
      Write_Pointer, Read_Pointer : Byte_Buffer_Index := 0; -- Next byte to be written to or read from

      -- Boolean flags are used to store client requests and server notifications, the associated data is obviously kept around
      Stream_End_Reached, Exception_Active : Boolean := False;
      Pending_Requests : Stream_Request_Status := (others => False);
      Seek_Destination : Universal_Address;
      Client_Exception : Ada.Exceptions.Exception_Occurrence;

      -- These hidden entries are used to synchronize clients and servers.
      entry Wait_For_Seek;
      entry Wait_For_Exception_Fetch;
   end Byte_Stream;

   -- As any asynchronous communication primitive, byte streams are likely to require reference counted handles (one for server, one for client)
   package Shared_Byte_Streams is new Tasking.Shared_Resources (Resource => Byte_Stream);
   subtype Byte_Stream_Access is Shared_Byte_Streams.Resource_Access;
   subtype Byte_Stream_Handle is Shared_Byte_Streams.Resource_Handle;
   function Is_Valid (Handle : Byte_Stream_Handle) return Boolean renames Shared_Byte_Streams.Is_Valid;
   function Target (Handle : Byte_Stream_Handle) return not null Byte_Stream_Access renames Shared_Byte_Streams.Target;
   function Make_Byte_Stream (Buffer_Size : Byte_Buffer_Size; Chunk_Size : Byte_Buffer_Size) return Byte_Stream_Handle is
     (Shared_Byte_Streams.Make_Shared (new Byte_Stream (Buffer_Size, Chunk_Size)));

end Emulator_Kit.Memory.Byte_Streams;
