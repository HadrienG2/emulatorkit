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
with Emulator_Kit.Tasking.Processes.Unit_Tests;

package body Emulator_Kit.Tasking.Processes is

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

begin

   -- Automatically test the package when it is included
   Debug.Test.Elaboration_Self_Test (Unit_Tests.Run_Tests'Access);

end Emulator_Kit.Tasking.Processes;
