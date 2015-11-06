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

-- This package hierarchy provides debugging functionality
package Emulator_Kit.Debug is

   -- Display a debug message
   procedure Message (Contents : String);

   -- Display a debug message featuring task identification information
   procedure Task_Message (Contents : String);

   -- Display a debug message reporting an unhandled exception within a task
   procedure Task_Message_Unhandled_Exception (Occurrence : Ada.Exceptions.Exception_Occurrence);

end Emulator_Kit.Debug;
