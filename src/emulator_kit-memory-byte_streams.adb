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

with Emulator_Kit.Debug.Test; pragma Elaborate_All (Emulator_Kit.Debug.Test);

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

         -- If attempting to read data beyond the end of the stream, raise an exception
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

      function Clients_Waiting_For_Seek return Natural is (Wait_For_Seek'Count);

      function Servers_Waiting_For_Exception_Fetch return Natural is (Wait_For_Exception_Fetch'Count);

      entry Wait_For_Seek when not Seek_Requested or else Exception_Pending is
      begin
         if Exception_Pending then
            Fetch_Exception;
         end if;
      end Wait_For_Seek;

      entry Wait_For_Exception_Fetch when not Exception_Active is
      begin
         null;
      end Wait_For_Exception_Fetch;

   end Byte_Stream;

   procedure Run_Tests is
      use Emulator_Kit.Debug.Test;

      procedure Test_Byte_Stream is
         use type Data_Types.Byte;
         use type Byte_Buffer;
      begin
         -- Test initial stream state
         declare
            Stream : Byte_Stream (Buffer_Size => 1, Chunk_Size => 1);
            Request : Stream_Request;
         begin
            Test_Element_Property (Stream.Available_Storage = 1, "A newly created stream should have storage available");
            Test_Element_Property (Stream.Available_Data = 0, "A newly created stream should have no data available");
            Test_Element_Property (not Stream.Exception_Pending, "A newly created stream should have no pending exception");
            Test_Element_Property (not Stream.At_End, "A newly created stream should not be marked as having reached its end");
            Test_Element_Property (not Stream.Request_Pending, "A newly created stream should have no pending request");
            Test_Element_Property (not Stream.Stop_Requested and then not Stream.Seek_Requested, "A newly created stream should not lie about its request status");
            select
               Stream.Wait_For_Request (Request);
               Fail_Test ("Since there are no server requests initially, waiting for them should cause the server to block");
            else
               null;
            end select;
         end;

         -- Test basic stream I/O by exchanging one byte of data
         declare
            Stream : Byte_Stream (Buffer_Size => 1, Chunk_Size => 1);
            Input : constant Byte_Buffer (42 .. 42) := (42 => 24);
            Output : Byte_Buffer (32 .. 32) := (32 => 64);
         begin
            select
               Stream.Read_Data_Chunk (Output, Output'First);
               Fail_Test ("Stream reading should block when the stream is empty");
            else
               null;
            end select;
            select
               Stream.Write_Data_Chunk (Input, Input'First);
               Test_Element_Property (Stream.Available_Storage = 0, "Stream storage should decrease after writing a byte");
               Test_Element_Property (Stream.Available_Data = 1, "Stream data should appear after writing a byte");
            else
               Fail_Test ("Stream writing should not block when storage is available");
            end select;
            select
               Stream.Write_Data_Chunk (Input, Input'First);
               Fail_Test ("Stream writing should block when the stream is full");
            else
               null;
            end select;
            select
               Stream.Read_Data_Chunk (Output, Output'First);
               Test_Element_Property (Stream.Available_Storage = 1, "Stream storage should increase after reading a byte");
               Test_Element_Property (Stream.Available_Data = 0, "Stream data should disappear after reading a bye");
               Test_Element_Property (Output (32) = 24, "Data should be transmitted correctly within a stream");
            else
               Fail_Test ("Stream reading should not block when data is available");
            end select;
         end;

         -- Test stream ring buffer wraparound
         declare
            Stream : Byte_Stream (Buffer_Size => 2, Chunk_Size => 2);
            Input : constant Byte_Buffer (2 .. 5) := (2, 4, 6, 8);
            Output : Byte_Buffer (100 .. 103) := (10, 12, 14, 16);
         begin
            select
               Stream.Write_Data_Chunk (Input, Input'First);
            else
               Fail_Test ("Stream writing should not block when storage is available");
            end select;
            select
               Stream.Read_Data_Chunk (Output, Output'First);
            else
               Fail_Test ("Stream reading should not block when data is available");
            end select;
            select
               Stream.Write_Data_Chunk (Input, Input'First + Stream.Chunk_Size);
            else
               Fail_Test ("Stream writing should not block when storage is available");
            end select;
            select
               Stream.Read_Data_Chunk (Output, Output'First + Stream.Chunk_Size);
               Test_Element_Property (Stream.Available_Storage = Stream.Buffer_Size, "Stream storage be back to normal after emptying a stream");
               Test_Element_Property (Stream.Available_Data = 0, "The stream should be marked as empty after emptying it");
               Test_Element_Property (Output = Input, "Data should be transmitted correctly within a stream");
            else
               Fail_Test ("Stream reading should not block when data is available");
            end select;
         end;

         -- Test stream invalidation
         declare
            Stream : Byte_Stream (Buffer_Size => 1, Chunk_Size => 1);
            Input : constant Byte_Buffer (42 .. 42) := (42 => 24);
         begin
            select
               Stream.Write_Data_Chunk (Input, Input'First);
               Stream.Invalidate_Buffer;
               Test_Element_Property (Stream.Available_Storage = 1, "Stream storage should be back to normal after invalidation");
               Test_Element_Property (Stream.Available_Data = 0, "Stream data should be back to empty after invalidation");
            else
               Fail_Test ("Stream writing should not block when storage is available");
            end select;
         end;

         -- Test normal stream termination
         declare
            Stream : Byte_Stream (Buffer_Size => 1, Chunk_Size => 1);
            Input_Output : Byte_Buffer (32 .. 32) := (32 => 64);
         begin
            Stream.Notify_Stream_End;
            Test_Element_Property (Stream.At_End, "The client should be aware that a stream has reached its end");
            begin
               select
                  Stream.Read_Data_Chunk (Input_Output, Input_Output'First);
               else
                  Fail_Test ("Reading from an empty stream should not block when the stream has reached its end");
               end select;
            exception
               when Reached_Stream_End => null;
            end;
            begin
               Stream.Write_Data_Chunk (Input_Output, Input_Output'First);
               select
                  Stream.Write_Data_Chunk (Input_Output, Input_Output'First);
               else
                  Fail_Test ("Writing to a full stream should not block when the stream has reached its end");
               end select;
            exception
               when Reached_Stream_End => null;
            end;
         end;

         -- Test client stream stop request
         declare
            Stream : Byte_Stream (Buffer_Size => 1, Chunk_Size => 1);
            Request : Stream_Request;
         begin
            Stream.Request_Stop;
            Test_Element_Property (Stream.Request_Pending, "The server should be aware that the client has requested something");
            Test_Element_Property (Stream.Stop_Requested, "The server should be aware that the client has requested a stream stop");
            select
               Stream.Wait_For_Request (Request);
               Test_Element_Property (Request = Stop, "Waiting for the stop request should also work");
            else
               Fail_Test ("Waiting for a request should not block when a stop request is active");
            end select;
            Stream.Notify_Stream_End;
            Test_Element_Property (not Stream.Request_Pending, "After fulfilling the stop request, the stream should return to its normal state");
            Test_Element_Property (not Stream.Stop_Requested, "After fulfilling the stop request, the stream should return to its normal state");
         end;

         -- Test client stream seek request. Since we must check that the client blocks, this test will be quite a bit more involved...
         declare
            Stream : Byte_Stream (Buffer_Size => 1, Chunk_Size => 1);
            Destination : constant Universal_Address := 16#DEADBEEF#;
            Request : Stream_Request;
            Request_Sent : Boolean := False;
            Request_Processed : Boolean := False;

            task Client is
               entry Send_Request;
               entry Wait_For_Completion;
            end Client;

            task Server is
               entry Process_Request;
            end Server;

            task body Client is
            begin
               -- Sending the seek request will cause the client to block, so we must do it outside of the rendezvous
               accept Send_Request do
                  null;
               end Send_Request;
               Stream.Request_Seek (Destination);
               Request_Sent := True;
               Test_Element_Property (Request_Processed, "The client should wait until the server has processed the request");
               accept Wait_For_Completion  do
                  null;
               end Wait_For_Completion;
            exception
               when Occurrence : others =>
                  Debug.Task_Message_Unhandled_Exception (Occurrence);
            end Client;

            task body Server is
            begin
               accept Process_Request do
                  Request_Processed := True;
                  Test_Element_Property (Stream.Request_Pending, "The server should be aware that the client has requested something");
                  Test_Element_Property (Stream.Seek_Requested, "The server should be aware that the client has requested a stream seek");
                  Stream.Wait_For_Request (Request);
                  Test_Element_Property (Request = Seek, "Waiting for the seek request should also work");
                  Test_Element_Property (Stream.Seek_Address = Destination, "The server should have the right seek address in mind");
                  Stream.Notify_Seek_Completion;
                  Test_Element_Property (not Stream.Request_Pending, "After fulfilling the seek request, the stream should return to its normal state");
                  Test_Element_Property (not Stream.Seek_Requested, "After fulfilling the seek request, the stream should return to its normal state");
               end Process_Request;
            exception
               when Occurrence : others =>
                  Debug.Task_Message_Unhandled_Exception (Occurrence);
            end Server;
         begin
            select
               -- Give our tasks one second to seek the stream
               delay 1.0;
               Fail_Test ("Client or server hung during stream seek request");
            then abort
               -- Have our client task send the seek request
               Client.Send_Request;

               -- Wait until the client either 1/Is waiting for the server to fulfill the seek request, or 2/Has failed to wait
               while Stream.Clients_Waiting_For_Seek = 0 and then not Request_Sent loop
                  delay 0.001;
               end loop;

               -- Have our server task process the seek request, then check that client execution was resumed properly
               Server.Process_Request;
               Client.Wait_For_Completion;
            end select;
         end;

         -- Test basic exception reporting. As before, there is blocking behavior in there and we must check that the server does indeed block.
         declare
            Stream : Byte_Stream (Buffer_Size => 1, Chunk_Size => 1);
            Silly_Exception : exception;
            Silly_Message : constant String := "Well, hello there !";
            Exception_Notified : Boolean := False;
            Exception_Processed : Boolean := False;

            task Client is
               entry Fetch_Exception;
            end Client;

            task Server is
               entry Send_Exception;
               entry Wait_For_Completion;
            end Server;

            task body Client is
            begin
               accept Fetch_Exception do
                  Exception_Processed := True;
                  Test_Element_Property (Stream.Exception_Pending, "The client should be aware that an exception is pending");
                  begin
                     Stream.Fetch_Exception;
                  exception
                     when Occurrence : Silly_Exception =>
                        Test_Element_Property (Ada.Exceptions.Exception_Message (Occurrence) = Silly_Message, "Exceptions should be transmitted well");
                  end;
                  Test_Element_Property (not Stream.Exception_Pending, "Fetching an exception should mark it as processed");
               end Fetch_Exception;
            exception
               when Occurrence : others =>
                  Debug.Task_Message_Unhandled_Exception (Occurrence);
            end Client;

            task body Server is
            begin
               -- As before, sending the exception will cause the server to block, so we must do it outside of the rendezvous.
               accept Send_Exception do
                  null;
               end Send_Exception;
               begin
                  raise Silly_Exception with Silly_Message;
               exception
                  when Occurrence : Silly_Exception =>
                     Stream.Notify_Exception (Occurrence);
                     Exception_Notified := True;
               end;
               Test_Element_Property (Exception_Processed, "The server should wait until the client has processed the request");
               accept Wait_For_Completion  do
                  null;
               end Wait_For_Completion;
            exception
               when Occurrence : others =>
                  Debug.Task_Message_Unhandled_Exception (Occurrence);
            end Server;
         begin
            select
               -- Give our tasks one second to process the exception
               delay 1.0;
               Fail_Test ("Client or server hung during stream exception handling");
            then abort
               -- Have our server raise an exception
               Server.Send_Exception;

               -- Wait until the server either 1/Is waiting for the client to fetch the exception, or 2/Has failed to wait
               while Stream.Servers_Waiting_For_Exception_Fetch = 0 and then not Exception_Notified loop
                  delay 0.001;
               end loop;

               -- Have our client task process the exception, then check that server execution was resumed properly
               Client.Fetch_Exception;
               Server.Wait_For_Completion;
            end select;
         end;

         -- Test the impact of server exceptions on client reads, writes and seeks
         declare
            Stream : Byte_Stream (Buffer_Size => 0, Chunk_Size => 1); -- Silly buffer size chosen such that both reads and writes will block
            Stupid_Exception : exception;

            task Client is
               entry Wait_For_Completion;
            end Client;

            task Server is
               entry Wait_For_Completion;
            end Server;

            task body Client is
               Client_Buffer : Byte_Buffer (33 .. 33);
            begin
               begin
                  Stream.Read_Data_Chunk (Client_Buffer, Client_Buffer'First);
                  Fail_Test ("Client reads should fetch pending exceptions");
               exception
                  when Stupid_Exception => null;
               end;
               begin
                  Stream.Write_Data_Chunk (Client_Buffer, Client_Buffer'First);
                  Fail_Test ("Client writes should fetch pending exceptions");
               exception
                  when Stupid_Exception => null;
               end;
               begin
                  Stream.Request_Seek (16#BADC0DE#);
                  Fail_Test ("Client seeks should propagate pending exceptions");
               exception
                  when Stupid_Exception => null;
               end;
               accept Wait_For_Completion do
                  null;
               end Wait_For_Completion;
            exception
               when Occurrence : others =>
                  Debug.Task_Message_Unhandled_Exception (Occurrence);
            end Client;

            task body Server is
               Seek_Request : Stream_Request;
            begin
               begin
                  raise Stupid_Exception with "Failure is the only option !";
               exception
                  when Occurrence : Stupid_Exception =>
                     Stream.Notify_Exception (Occurrence);
                     Stream.Notify_Exception (Occurrence);
                     Stream.Wait_For_Request (Seek_Request);
                     Stream.Notify_Exception (Occurrence);
               end;
               accept Wait_For_Completion  do
                  null;
               end Wait_For_Completion;
            exception
               when Occurrence : others =>
                  Debug.Task_Message_Unhandled_Exception (Occurrence);
            end Server;
         begin
            select
               -- Give our tasks one second to process all exceptions
               delay 1.0;
               Fail_Test ("Client or server hung during stream exception handling");
            then abort
               Client.Wait_For_Completion;
               Server.Wait_For_Completion;
            end select;
         end;
      end Test_Byte_Stream;

      procedure Test_Byte_Streams_Package is
      begin
         Test_Package_Element (To_Entity_Name ("Byte_Stream"), Test_Byte_Stream'Access);
         -- NOTE : We will NOT test shared streams, since shared resources are already tested as part of Tasking.Processes' tests
      end Test_Byte_Streams_Package;
   begin
      Test_Package (To_Entity_Name ("Memory.Byte_Streams"), Test_Byte_Streams_Package'Access);
   end Run_Tests;

begin

   -- Automatically test the package when it is included
   Debug.Test.Elaboration_Self_Test (Run_Tests'Access);

end Emulator_Kit.Memory.Byte_Streams;
