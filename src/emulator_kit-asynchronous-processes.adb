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

with Emulator_Kit.Debug.Test;

package body Emulator_Kit.Asynchronous.Processes is

   use type Ada.Exceptions.Exception_Id;

   protected body Process is

      procedure Notify_Exception (Server_Exception : Ada.Exceptions.Exception_Occurrence) is
      begin
         Ada.Exceptions.Save_Occurrence (Source => Server_Exception,
                                         Target => Client_Exception);
         Exception_Active := True;
         Notify_Completion;
      end Notify_Exception;

      procedure Notify_Completion is
      begin
         Process_Completed := True;
      end Notify_Completion;

      function Exception_Pending return Boolean is (Exception_Active);

      procedure Fetch_Exception is
      begin
         Ada.Exceptions.Reraise_Occurrence (Client_Exception);
      end Fetch_Exception;

      function Completed return Boolean is (Process_Completed);

      entry Wait_For_Completion when Process_Completed is
      begin
         Fetch_Exception;
      end Wait_For_Completion;

   end Process;

   procedure Test is
      use Emulator_Kit.Debug.Test;

      procedure Test_Process is
      begin
         -- Check the normal process workflow
         declare
            Proc : Process;
         begin
            -- Check initial process state
            Test_Element_Property (not Proc.Completed, "Processes should not be initially completed");
            Test_Element_Property (not Proc.Exception_Pending, "Processes should not initially have exceptions");
            begin
               Proc.Fetch_Exception;
            exception
               when others => Fail_Test ("Fetching exceptions should do nothing initially");
            end;
            select
               Proc.Wait_For_Completion;
               Fail_Test ("Client should wait for unfinished process when calling Wait_For_Completion");
            else
               null;
            end select;

            -- Check process state after normal completion
            Proc.Notify_Completion;
            Test_Element_Property (Proc.Completed, "After completion notification, processes should be completed");
            Test_Element_Property (not Proc.Exception_Pending, "After completion notification, processes should not have exceptions");
            begin
               Proc.Fetch_Exception;
            exception
               when others => Fail_Test ("After completion notification, fetching exceptions should do nothing");
            end;
            select
               Proc.Wait_For_Completion;
            else
               Fail_Test ("Client should not wait for finished processes");
            end select;
         end;

         -- Check the exceptional process workflow
         declare
            Proc : Process;
            Strange_Exception : exception;
            Strange_Message : constant String := "Strange message";
         begin
            -- Raise a process exception
            begin
               raise Strange_Exception with Strange_Message;
            exception
               when Occurrence : Strange_Exception => Proc.Notify_Exception (Occurrence);
            end;

            -- Check the resulting process state
            Test_Element_Property (Proc.Completed, "After exception notification, processes should be completed");
            Test_Element_Property (Proc.Exception_Pending, "After exception notification, processes should have an exception pending");
            begin
               Proc.Fetch_Exception;
               Fail_Test ("When an exception is pending, Fetch_Exception should trigger it");
            exception
               when Occurrence : Strange_Exception =>
                  Test_Element_Property (Ada.Exceptions.Exception_Message (Occurrence) = Strange_Message,
                                         "Exception notifications should preserve the exception message");
               when others =>
                  Fail_Test ("Exception notifications should preserve the exception type");
            end;
            begin
               select
                  Proc.Wait_For_Completion;
                  Fail_Test ("When an exception is pending, Wait_For_Completion should trigger it");
               else
                  Fail_Test ("Client should not wait for aborted processes");
               end select;
            exception
               when Occurrence : Strange_Exception =>
                  Test_Element_Property (Ada.Exceptions.Exception_Message (Occurrence) = Strange_Message,
                                         "Exception notifications should preserve the exception message");
               when others =>
                  Fail_Test ("Exception notifications should preserve the exception type");
            end;
         end;
      end Test_Process;

      procedure Test_Shared_Processes is
         use type Process_Access;
      begin
         -- Check the uninitialized process handle state
         begin
            -- Test single handle behaviour
            declare
               Proc_Handle : Process_Handle;
            begin
               Test_Element_Property (not Proc_Handle.Is_Valid, "Process handles should be initially invalid");
               declare
                  Handle_Target : Process_Access with Unreferenced;
               begin
                  Handle_Target := Process_Handle.Target;
                  Fail_Test ("Accessing an invalid handle should trigger an exception");
               exception
                  when Shared_Processes.Invalid_Handle => null;
                  when others => Fail_Test ("Invalid handle access should raise Invalid_Handle");
               end;
            end;

            -- Test copying behaviour
            declare
               Proc_Handle_1 : Process_Handle;
               Proc_Handle_2 : Process_Handle with Unreferenced;
            begin
               Proc_Handle_2 := Proc_Handle_1;
               Fail_Test ("Copying an invalid handle should trigger an exception");
            exception
               when Program_Error => null;
               when others => Fail_Test ("Invalid handle copy should raise Program_Error");
            end;
         exception
            when others => Fail_Test ("No valid part of the handle lifecycle should trigger exceptions");
         end;

         -- Check shared handle initialization, copying behavior, and finalization
         begin
            -- Test a single "shared" handle
            declare
               Proc_Handle : constant Process_Handle := Make_Process;
            begin
               Test_Element_Property (Proc_Handle.Is_Valid, "Newly cleated handles should be valid");
               declare
                  Handle_Target : Process_Access with Unreferenced;
               begin
                  Handle_Target := Proc_Handle.Target;
               exception
                  when others => Fail_Test ("Accessing the target of a valid handle should trigger no exception");
               end;
            end;

            -- Test shared handle ownership transmission
            declare
               Proc_Handle_2 : Process_Handle;
            begin
               -- Create a handle and transmit its ownership
               declare
                  Proc_Handle_1 : constant Process_Handle := Make_Process;
               begin
                  Proc_Handle_2 := Proc_Handle_1;
                  Test_Element_Property (Proc_Handle_2.Is_Valid, "A copy of a valid handle should be valid");
                  Test_Element_Property (Proc_Handle_2.Target = Proc_Handle_1.Target, "Handle copies should have the same target as the original");
               end;

               -- Check that after original handle termination, the handle copy is still valid
               Test_Element_Property (Proc_Handle_2.Is_Valid, "A handle copy should remain valid when the original is gone");
               declare
                  Handle_Target : Process_Access with Unreferenced;
               begin
                  Handle_Target := Proc_Handle_2.Target;
               exception
                  when others => Fail_Test ("Accessing the target of a valid handle copy should trigger no exception");
               end;
            end;
         exception
            when others => Fail_Test ("No valid part of the handle lifecycle should trigger exceptions");
         end;
      end Test_Shared_Processes;

      procedure Test_Processes_Package is
      begin
         Test_Package_Element (To_Entity_Name ("Process"), Test_Process'Access);
         Test_Package_Element (To_Entity_Name ("Shared_Processes"), Test_Shared_Processes'Access);
      end Test_Processes_Package;
   begin
      Test_Package (To_Entity_Name ("Asynchronous.Processes"), Test_Processes_Package'Access);
   end Test;

begin

   -- Automatically test the package when it is included
   Debug.Test.Elaboration_Self_Test (Test'Access);

end Emulator_Kit.Asynchronous.Processes;
