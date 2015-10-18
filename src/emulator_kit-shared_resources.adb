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

with Ada.Unchecked_Deallocation;

package body Emulator_Kit.Shared_Resources is

   function Is_Valid (Handle : Resource_Handle) return Boolean is (Handle.Shared /= null);

   function Target (Handle : Resource_Handle) return not null Resource_Access is
   begin
      if Handle.Is_Valid then
         return Handle.Shared.Internal_Resource;
      else
         raise Invalid_Handle;
      end if;
   end Target;

   function Make_Shared (Target : not null Resource_Access) return Resource_Handle is
   begin
      return Handle : Resource_Handle do
         Handle.Shared := new Shared_Resource'(Internal_Resource => Target,
                                               Handle_Count => 1);
      end return;
   end Make_Shared;

   procedure Adjust (Handle : in out Resource_Handle) is
   begin
      if Handle.Is_Valid then
         Handle.Shared.Handle_Count := Handle.Shared.Handle_Count + 1;
      else
         raise Invalid_Handle;
      end if;
   end Adjust;

   procedure Finalize (Handle : in out Resource_Handle) is
      procedure Liberate_Resource is new Ada.Unchecked_Deallocation (Object => Resource,
                                                                     Name => Resource_Access);
      procedure Liberate_Shared is new Ada.Unchecked_Deallocation (Object => Shared_Resource,
                                                                   Name => Shared_Resource_Access);
   begin
      if Handle.Is_Valid then
         Handle.Shared.Handle_Count := Handle.Shared.Handle_Count - 1;
         if Handle.Shared.Handle_Count = 0 then
            Liberate_Resource (Handle.Shared.Internal_Resource);
            Liberate_Shared (Handle.Shared);
         end if;
      end if;
   end Finalize;

end Emulator_Kit.Shared_Resources;
