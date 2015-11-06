-- Unit tests for abstract memory are special in that they expect an instance of the interface
package Emulator_Kit.Memory.Abstract_Memory.Unit_Tests is

   -- The unit test runner should already be initialized with the instance package's parameters
   -- The provided instance should have at least 128 bytes of storage
   procedure Instance_Tests (Instance : in out Memory_Interface'Class);

end Emulator_Kit.Memory.Abstract_Memory.Unit_Tests;
