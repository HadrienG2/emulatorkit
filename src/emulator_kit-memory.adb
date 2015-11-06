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

package body Emulator_Kit.Memory is

   function "-"(Left : Universal_Address; Right : Universal_Address) return Universal_Size is
   begin
      if Left < Right then
         raise Illegal_Address;
      else
         return Universal_Size (Left) - Universal_Size (Right);
      end if;
   end "-";

   function "+"(Left : Universal_Address; Right : Universal_Size) return Universal_Address is
   begin
      if Left > Universal_Address (-Right) then
         raise Illegal_Address;
      else
         return Universal_Address (Universal_Size (Left) + Right);
      end if;
   end "+";

   function "-"(Left : Universal_Address; Right : Universal_Size) return Universal_Address is
   begin
      if Right > Universal_Size (Left) then
         raise Illegal_Address;
      else
         return Universal_Address (Universal_Size (Left) - Right);
      end if;
   end "-";

   procedure Run_Tests is
      use Emulator_Kit.Debug.Test;

      procedure Test_Universal is
      begin
         -- Check universal address subtraction
         declare
            Address_1 : constant Universal_Address := 64;
            Address_2 : constant Universal_Address := 42;
         begin
            Test_Element_Property (Address_1 - Address_2 = Universal_Size'(22), "Universal address subtraction should work");
            declare
               Illegal_Size : Universal_Size with Unreferenced;
            begin
               Illegal_Size := Address_2 - Address_1;
               Fail_Test ("Negative address differences should be illegal");
            exception
               when Illegal_Address => null;
               when others => Fail_Test ("Negative address differences should raise Illegal_Address");
            end;
         end;

         -- Check appplication of offsets to addresses
         declare
            Address : constant Universal_Address := 2 ** 52;
         begin
            -- Simple positive and negative offsets
            declare
               Reasonable_Size : constant Universal_Size := 2 ** 52;
            begin
               Test_Element_Property (Address + Reasonable_Size = Universal_Address'(2 ** 53), "Positive address offsetting should work");
               Test_Element_Property (Address - Reasonable_Size = Universal_Address'(0), "Negative address offsetting should work");
            end;

            -- Check address overflow and underflow detection
            declare
               Unreasonable_Size : constant Universal_Size := Universal_Size'Last;
               Unreasonable_Address : Universal_Address with Unreferenced;
            begin
               -- Address overflow
               begin
                  Unreasonable_Address := Address + Unreasonable_Size;
                  Fail_Test ("Unreasonable positive address offsetting should be illegal");
               exception
                  when Illegal_Address => null;
                  when others => Fail_Test ("Unreasonable positive address offseting should raise Illegal_Address");
               end;

               -- Address underflow
               begin
                  Unreasonable_Address := Address - Unreasonable_Size;
                  Fail_Test ("Unreasonable negative address offsetting should be illegal");
               exception
                  when Illegal_Address => null;
                  when others => Fail_Test ("Unreasonable negative address offseting should raise Illegal_Address");
               end;
            end;
         end;
      end Test_Universal;

      procedure Test_Memory_Package is
      begin
         Test_Package_Element (To_Entity_Name ("Universal_*"), Test_Universal'Access);
      end Test_Memory_Package;
   begin
      Test_Package (To_Entity_Name ("Memory"), Test_Memory_Package'Access);
   end Run_Tests;

begin

   -- Automatically test the package when it is included
   Debug.Test.Elaboration_Self_Test (Run_Tests'Access);

end Emulator_Kit.Memory;
