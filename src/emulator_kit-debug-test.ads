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

with Ada.Strings;
with Ada.Strings.Bounded;

-- This package provides a simple unit test runner
package Emulator_Kit.Debug.Test is

   -- If a test does not pass, it will raise this exception
   Test_Failed : exception;

   -- The boolean flag centrally enables or disables package self-testing by the function below
   Test_On_Elaboration : Boolean := True;
   procedure Elaboration_Self_Test (Testing_Procedure : not null access procedure);

   -- We shall use this string type for package and package element element names
   Max_Entity_Name_Length : constant := 256;
   package Entity_Names is new Ada.Strings.Bounded.Generic_Bounded_Length (Max => Max_Entity_Name_Length);
   subtype Entity_Name is Entity_Names.Bounded_String;
   function To_Entity_Name (Source : String;
                            Drop : Ada.Strings.Truncation := Ada.Strings.Error) return Entity_Name renames Entity_Names.To_Bounded_String;
   function To_String (Source : Entity_Name) return String renames Entity_Names.To_String;

   -- Clients need not add the "Emulator_Kit." prefix to package names, nor the package name to element names, as it shall be prepended automatically
   -- However, the length of the string must be right.
   Entity_Prefix : constant Entity_Name := To_Entity_Name ("Emulator_Kit.");
   function Valid_Package_Name (Prospective_Name : Entity_Name) return Boolean;
   function Valid_Element_Name (Prospective_Name : Entity_Name) return Boolean;

   -- The test runner is a state machine internally, this allows us to check its status
   function Package_Test_Running return Boolean;
   function Element_Test_Running return Boolean;

   -- Run tests for a complete package
   procedure Test_Package (Package_Name : Entity_Name; Testing_Procedure : not null access procedure)
     with Pre => (not Package_Test_Running and then
                      Valid_Package_Name (Package_Name));

   -- Run tests for a single package element (package testing procedures should call this)
   procedure Test_Package_Element (Element_Name : Entity_Name; Testing_Procedure : not null access procedure)
     with Pre => (Package_Test_Running and then
                    not Element_Test_Running and then
                      Valid_Element_Name (Element_Name));

   -- Check a single assertion about an element, with a human-readable failure message such as "1 + 1 should be equal to 2"
   procedure Test_Element_Property (Property : Boolean; Failure_Message : String)
     with Pre => Element_Test_Running;
   procedure Fail_Test (Failure_Message : String)
     with Pre => Element_Test_Running;

private

   Global_Package_Test_Running : Boolean := False;
   function Package_Test_Running return Boolean is (Global_Package_Test_Running);

   Global_Element_Test_Running : Boolean := False;
   function Element_Test_Running return Boolean is (Global_Element_Test_Running);

   function Valid_Package_Name (Prospective_Name : Entity_Name) return Boolean is
     (Entity_Names.Length (Prospective_Name) < Max_Entity_Name_Length - Entity_Names.Length (Entity_Prefix));

   Global_Package_Prefix : Entity_Name;
   function Valid_Element_Name (Prospective_Name : Entity_Name) return Boolean is
     (Entity_Names.Length (Prospective_Name) < Max_Entity_Name_Length - Entity_Names.Length (Global_Package_Prefix));

end Emulator_Kit.Debug.Test;
