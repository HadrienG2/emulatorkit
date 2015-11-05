with Emulator_Kit.Debug.Test;
with Emulator_Kit.Memory; pragma Elaborate (Emulator_Kit.Memory); -- DEBUG : GNAT currently cannot figure this out on its own

package body Emulator_Kit.Memory.Unit_Tests is

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

end Emulator_Kit.Memory.Unit_Tests;
