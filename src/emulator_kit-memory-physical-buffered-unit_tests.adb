with Emulator_Kit.Debug.Test;
with Emulator_Kit.Memory.Physical.Buffered; pragma Elaborate (Emulator_Kit.Memory.Physical.Buffered); -- DEBUG : GNAT currently cannot figure this out on its own

package body Emulator_Kit.Memory.Physical.Buffered.Unit_Tests is

   procedure Run_Tests is
      use Emulator_Kit.Debug.Test;

      procedure Test_Buffer_Memory is
      begin
         -- TODO
         null;
      end Test_Buffer_Memory;

      procedure Test_Buffered_Package is
      begin
         Test_Package_Element (To_Entity_Name ("Buffer_Memory"), Test_Buffer_Memory'Access);
      end Test_Buffered_Package;
   begin
      Test_Package (To_Entity_Name ("Memory.Physical.Buffered"), Test_Buffered_Package'Access);
   end Run_Tests;

end Emulator_Kit.Memory.Physical.Buffered.Unit_Tests;
