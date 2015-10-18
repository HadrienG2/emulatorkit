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

with Ada.Task_Identification;
with Ada.Text_IO;

package body Emulator_Kit.Debug is

   procedure Message (Contents : String) is
   begin
      Ada.Text_IO.Put_Line ("DEBUG : " & Contents);
   end Message;

   procedure Task_Message (Contents : String) is
      use Ada.Task_Identification;
   begin
      Ada.Text_IO.Put_Line ("DEBUG FROM " & Image (Current_Task) & " : " & Contents);
   end Task_Message;

   procedure Message_Unhandled_Exception (Occurrence : Ada.Exceptions.Exception_Occurrence) is
   begin
      Message ("Unhandled exception of type " &
                 Ada.Exceptions.Exception_Name (Occurrence) & ", with message """ &
                 Ada.Exceptions.Exception_Message (Occurrence) & """ ! Aborting...");
   end Message_Unhandled_Exception;

   procedure Task_Message_Unhandled_Exception (Occurrence : Ada.Exceptions.Exception_Occurrence) is
   begin
      Task_Message ("Unhandled exception of type " &
                      Ada.Exceptions.Exception_Name (Occurrence) & ", with message """ &
                      Ada.Exceptions.Exception_Message (Occurrence) & """ ! Aborting...");
   end Task_Message_Unhandled_Exception;

end Emulator_Kit.Debug;
