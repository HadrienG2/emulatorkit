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
with Emulator_Kit.Tasking.Shared_Resources;

-- This package sets up a basic interface to ongoing asynchronous processes
package Emulator_Kit.Tasking.Processes is

   -- Represents an ongoing process that will be completed at some point
--     protected type Process is new Exception_Channel with  -- DEBUG : This should work, but doesn't on GNAT GPL 2015
   protected type Process is  -- DEBUG : This works

      -- Server interface
      procedure Notify_Exception (Server_Exception : Ada.Exceptions.Exception_Occurrence); -- Implicitly notifies completion as well
      procedure Notify_Completion;

      -- Client interface
      function Exception_Pending return Boolean;
      procedure Fetch_Exception;
      function Completed return Boolean;
      entry Wait_For_Completion;

   private
      Process_Completed, Exception_Active : Boolean := False;
      Client_Exception : Ada.Exceptions.Exception_Occurrence;
   end Process;

   -- As any asynchronous communication primitive, processes are likely to require reference counted handles (one for server, one for client)
   package Shared_Processes is new Shared_Resources (Resource => Process);
   subtype Process_Access is Shared_Processes.Resource_Access;
   subtype Process_Handle is Shared_Processes.Resource_Handle;
   function Is_Valid (Handle : Process_Handle) return Boolean renames Shared_Processes.Is_Valid;
   function Target (Handle : Process_Handle) return not null Process_Access renames Shared_Processes.Target;
   function Make_Process return Process_Handle is (Shared_Processes.Make_Shared (new Process));

   -- Test the components of this package
   procedure Test;

end Emulator_Kit.Tasking.Processes;
