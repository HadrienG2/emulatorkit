with Emulator_Kit.Debug.Test;
with Emulator_Kit.Memory.Physical.Buffered; pragma Elaborate (Emulator_Kit.Memory.Physical.Buffered); -- DEBUG : GNAT currently cannot figure this out on its own
with Emulator_Kit.Memory.Abstract_Memory.Unit_Tests;

package body Emulator_Kit.Memory.Physical.Buffered.Unit_Tests is

   procedure Run_Tests is
      use Emulator_Kit.Debug.Test;

      procedure Test_Buffer_Memory is
         Buffer_Mem : Buffer_Memory (256); -- This amount of memory makes for nice test patterns
      begin
         Abstract_Memory.Unit_Tests.Instance_Tests (Buffer_Mem);
      end Test_Buffer_Memory;

      procedure Test_Buffered_Package is
      begin
         Test_Package_Element (To_Entity_Name ("Buffer_Memory"), Test_Buffer_Memory'Access);
      end Test_Buffered_Package;
   begin
      Test_Package (To_Entity_Name ("Memory.Physical.Buffered"), Test_Buffered_Package'Access);
   end Run_Tests;

end Emulator_Kit.Memory.Physical.Buffered.Unit_Tests;
