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

package body Emulator_Kit.Memory.Byte_Streams is

   use type Ada.Exceptions.Exception_Id;
   use type Byte_Buffer_Index;

   protected body Byte_Stream is

      procedure Invalidate_Buffer is
      begin
         Write_Pointer := Read_Pointer;
      end Invalidate_Buffer;

      function Available_Storage return Byte_Buffer_Size is ((Read_Pointer - Write_Pointer - 1) mod Ring_Buffer'Length);

      entry Write_Data_Chunk (Input : Byte_Buffer; Input_Index : Byte_Buffer_Index)
        when (Available_Storage >= Chunk_Size or else Stream_End_Reached or else Exception_Active)
      is
         Input_End : constant Byte_Buffer_Index := Input_Index + Chunk_Size - 1;
         Write_End : constant Byte_Buffer_Index := (Write_Pointer + Chunk_Size - 1) mod Ring_Buffer'Length;
      begin
         -- If a client exception is pending, raise it
         if Exception_Active then
            Fetch_Exception;
         end if;

         -- Raise an exception if attempting to write data beyond the end of the stream.
         if Available_Storage < Chunk_Size then
            raise Reached_Stream_End;
         end if;

         -- Otherwise, write the pending data chunk to the stream
         if Write_End >= Write_Pointer then
            Ring_Buffer (Write_Pointer .. Write_End) := Input (Input_Index .. Input_End);
         else
            declare
               First_Pass_Items : constant Byte_Buffer_Size := Ring_Buffer'Last - Write_Pointer + 1;
            begin
               Ring_Buffer (Write_Pointer .. Ring_Buffer'Last) := Input (Input_Index .. Input_Index + First_Pass_Items - 1);
               Ring_Buffer (Ring_Buffer'First .. Write_End) := Input (Input_Index + First_Pass_Items .. Input_End);
            end;
         end if;
         Write_Pointer := (Write_End + 1) mod Ring_Buffer'Length;
      end Write_Data_Chunk;

      function Available_Data return Byte_Buffer_Size is ((Write_Pointer - Read_Pointer) mod Ring_Buffer'Length);

      entry Read_Data_Chunk (Output : out Byte_Buffer; Output_Index : Byte_Buffer_Index)
        when (Available_Data >= Chunk_Size or else Stream_End_Reached or else Exception_Active)
      is
         Read_End : constant Byte_Buffer_Index := (Read_Pointer + Chunk_Size - 1) mod Ring_Buffer'Length;
         Output_End : constant Byte_Buffer_Index := Output_Index + Chunk_Size - 1;
      begin
         -- If a client exception is pending, raise it
         if Exception_Active then
            Fetch_Exception;
         end if;

         -- Raise an exception if attempting to read data beyond the end of the stream.
         if Available_Data < Chunk_Size then
            raise Reached_Stream_End;
         end if;

         -- Otherwise, read a data chunk from the stream normally
         if Read_End >= Read_Pointer then
            Output (Output_Index .. Output_End) := Ring_Buffer (Read_Pointer .. Read_End);
         else
            declare
               First_Pass_Items : constant Byte_Buffer_Size := Ring_Buffer'Last - Read_Pointer + 1;
            begin
               Output (Output_Index .. Output_Index + First_Pass_Items - 1) := Ring_Buffer (Read_Pointer .. Ring_Buffer'Last);
               Output (Output_Index + First_Pass_Items .. Output_End) := Ring_Buffer (Ring_Buffer'First .. Read_End);
            end;
         end if;
         Read_Pointer := (Read_End + 1) mod Ring_Buffer'Length;
      end Read_Data_Chunk;

      function Exception_Pending return Boolean is (Exception_Active);

      procedure Fetch_Exception is
      begin
         Exception_Active := False;
         Ada.Exceptions.Reraise_Occurrence (Client_Exception);
      end Fetch_Exception;

      procedure Request_Stop is
      begin
         Pending_Requests (Stop) := True;
      end Request_Stop;

      function At_End return Boolean is (Stream_End_Reached and then Available_Data = 0);

      entry Request_Seek (Destination : Universal_Address) when True is
      begin
         Seek_Destination := Destination;
         Pending_Requests (Seek) := True;
         requeue Wait_For_Seek;
      end Request_Seek;

      entry Notify_Exception (Server_Exception : Ada.Exceptions.Exception_Occurrence) when True is
      begin
         Ada.Exceptions.Save_Occurrence (Source => Server_Exception,
                                         Target => Client_Exception);
         Exception_Active := True;
         requeue Wait_For_Exception_Fetch;
      end Notify_Exception;

      function Request_Pending return Boolean is (for some Request of Pending_Requests => Request);

      entry Wait_For_Request (Request : out Stream_Request) when Request_Pending is
      begin
         for Current_Request in Stream_Request loop
            if Pending_Requests (Current_Request) then
               Request := Current_Request;
               return;
            end if;
         end loop;
      end Wait_For_Request;

      function Stop_Requested return Boolean is (Pending_Requests (Stop));

      procedure Notify_Stream_End is
      begin
         Stream_End_Reached := True;
         Pending_Requests (Stop) := False;
      end Notify_Stream_End;

      function Seek_Requested return Boolean is (Pending_Requests (Seek));

      function Seek_Address return Universal_Address is (Seek_Destination);

      procedure Notify_Seek_Completion is
      begin
         Invalidate_Buffer;
         Pending_Requests (Seek) := False;
      end Notify_Seek_Completion;

      entry Wait_For_Seek when not Seek_Requested is
      begin
         Fetch_Exception;
      end Wait_For_Seek;

      entry Wait_For_Exception_Fetch when not Exception_Active is
      begin
         null;
      end Wait_For_Exception_Fetch;

   end Byte_Stream;

end Emulator_Kit.Memory.Byte_Streams;
