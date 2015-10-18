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

package body Emulator_Kit.Debug.Test is

   use type Entity_Name;

   Global_Element_Name : Entity_Name;

   procedure Elaboration_Self_Test (Testing_Procedure : not null access procedure) is
   begin
      if Test_On_Elaboration then
         Testing_Procedure.all;
      end if;
   end Elaboration_Self_Test;

   procedure Test_Package (Package_Name : Entity_Name; Testing_Procedure : not null access procedure) is
      Full_Package_Name : constant Entity_Name := Entity_Prefix & Package_Name;
   begin
      -- Take note that a package test is running
      Global_Package_Test_Running := True;

      -- Run the testing procedure
      Global_Package_Prefix := Full_Package_Name & '.';
      Testing_Procedure.all;

      -- Report success (if any)
      Debug.Message (To_String (Full_Package_Name) & " was successfully tested");

      -- Take note that the package test is over
      Global_Package_Test_Running := False;
   end Test_Package;

   procedure Test_Package_Element (Element_Name : Entity_Name; Testing_Procedure : not null access procedure) is
   begin
      -- Take note that an element test is running
      Global_Element_Test_Running := True;

      -- Run the testing procedure
      Global_Element_Name := Global_Package_Prefix & Element_Name;
      Testing_Procedure.all;

      -- Take note that the element test is over
      Global_Element_Test_Running := False;
   end Test_Package_Element;

   procedure Test_Element_Property (Property : Boolean; Failure_Message : String) is
   begin
      if not Property then
         Fail_Test (Failure_Message);
      end if;
   end Test_Element_Property;

   procedure Fail_Test (Failure_Message : String) is
   begin
      Debug.Message ("Testing of " & To_String (Global_Element_Name) & " failed - " & Failure_Message);
      raise Test_Failed;
   end Fail_Test;

end Emulator_Kit.Debug.Test;
