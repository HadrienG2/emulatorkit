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
with Emulator_Kit.Memory.Unit_Tests;

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

begin

   -- Automatically test the package when it is included
   Debug.Test.Elaboration_Self_Test (Unit_Tests.Run_Tests'Access);

end Emulator_Kit.Memory;
