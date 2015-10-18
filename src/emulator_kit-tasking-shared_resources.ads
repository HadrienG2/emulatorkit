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

with Ada.Finalization;

-- As a tasking program, this emulator is full of shared resources that must sometimes be dynamically created and liberated.
-- A typical use case is when a server task returns an asynchronous communication object to a client task as a response to a request.
-- This unit proposes a "resource handle" mechanism, in the spirit of C++ smart pointers, to tackle this common resource management problem.
generic
   type Resource (<>) is limited private; -- DEBUG : On GNAT GPL 2015, this fails to build when passed a tagged protected type
--     type Resource (<>) is tagged limited private; -- DEBUG : This works, but it does not do what I want
package Emulator_Kit.Tasking.Shared_Resources is

   -- First, we'll need pointers to resources allocated on a global scope.
   type Resource_Access is access all Resource;

   -- As Ada task entries may only be procedures (not functions), it is necessary to allow for an invalid "null" default resource handle state.
   -- However, an exception will be thrown if this null resource is used for any purpose other than assignment.
   type Resource_Handle is new Ada.Finalization.Controlled with private;
   Invalid_Handle : exception;

   -- Clients can query the validity of a resource handle or access the targeted resource
   function Is_Valid (Handle : Resource_Handle) return Boolean;
   function Target (Handle : Resource_Handle) return not null Resource_Access;

   -- The shared resource is allocated by the object creator, then ownership is transferred using the following function.
   -- Suggest usage is Make_Shared (new Resource (<resource discriminants>)).
   --
   -- The heap object received by Make_Shared stays live as long as at least one of its handles in in scope. It is then liberated.
   -- Handle copies are properly taken into account by incrementing or decrementing the shared resource's reference count.
   function Make_Shared (New_Target : not null Resource_Access) return Resource_Handle;

private

   -- Behind the scenes, a dynamically allocated control block is used to count the amount of references to resources.
   type Shared_Resource is
      record
         Internal_Resource : Resource_Access;
         Handle_Count : Natural := 0 with Atomic;
      end record;
   type Shared_Resource_Access is access Shared_Resource;

   -- All the resource handles do is point to this control block.
   type Resource_Handle is new Ada.Finalization.Controlled with
      record
         Shared : Shared_Resource_Access := null;
      end record;

   -- These procedures ensure that the resource reference count is incremented and decremented properly.
   overriding procedure Adjust (Handle : in out Resource_Handle);
   overriding procedure Finalize (Handle : in out Resource_Handle);

end Emulator_Kit.Tasking.Shared_Resources;
