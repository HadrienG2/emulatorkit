with Emulator_Kit.Debug.Test;
with Emulator_Kit.Memory.Byte_Streams; pragma Elaborate (Emulator_Kit.Memory.Byte_Streams); -- DEBUG : GNAT currently cannot figure this out on its own

package body Emulator_Kit.Memory.Byte_Streams.Unit_Tests is

   procedure Run_Tests is
      use Emulator_Kit.Debug.Test;

      procedure Test_Byte_Stream is
         use type Data_Types.Byte;
         use type Byte_Buffer;
         use type Byte_Buffer_Index;
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
            -- Have our client task send the seek request
            Client.Send_Request;

            -- Wait until the client either 1/Is waiting for the server to fulfill the seek request, or 2/Has failed to wait
            while Stream.Clients_Waiting_For_Seek = 0 and then not Request_Sent loop
               delay 0.001;
            end loop;

            -- Have our server task process the seek request, then check that client execution was resumed properly
            select
               Server.Process_Request;
            or
               delay 3.0;
               abort Client, Server;
               Fail_Test ("Server task hung during stream seek request");
            end select;
            select
               Client.Wait_For_Completion;
            or
               delay 3.0;
               abort Client, Server;
               Fail_Test ("Client task hung or crashed during stream seek request");
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
            -- Have our server raise an exception
            Server.Send_Exception;

            -- Wait until the server either 1/Is waiting for the client to fetch the exception, or 2/Has failed to wait
            while Stream.Servers_Waiting_For_Exception_Fetch = 0 and then not Exception_Notified loop
               delay 0.001;
            end loop;

            -- Have our client task process the exception, then check that server execution was resumed properly
            select
               Client.Fetch_Exception;
            or
               delay 3.0;
               abort Client, Server;
               Fail_Test ("Client task hung during exception processing");
            end select;
            select
               Server.Wait_For_Completion;
            or
               delay 3.0;
               abort Client, Server;
               Fail_Test ("Server task hung or crashed during exception processing");
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
               Client.Wait_For_Completion;
            or
               delay 3.0;
               abort Client, Server;
               Fail_Test ("Client task hung or crashed during exception processing");
            end select;
            select
               Server.Wait_For_Completion;
            or
               delay 3.0;
               abort Client, Server;
               Fail_Test ("Server task hung or crashed during exception processing");
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

end Emulator_Kit.Memory.Byte_Streams.Unit_Tests;
