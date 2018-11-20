### The Argon Language

Argon is a simple *traits* based language of my own design with *generic multimethods* and *mixins* called traits. 
( Multimethods are generic methods where dispatch is based on the type of every parameter AND the result type of a method, 
not just the single target of a method invocation as in traditional OO languages).
I started developing it because I wanted to achieve a few things

- I wanted to experiment with the concept of mixins ( called traits in this case )
- I wanted a language that had *multiple inheritance*, mixins, generic methods and traits based methods
- I wanted to learn some more advanced compiler techniques and optimizations
- I wanted to learn about generic multimethods
- I wanted to learn about designing opcode instruction formats
- I wanted to learn about writing a virtual machine

Argon ( which is still incomplete at this stage but advances more every day ) has a compiler that is a slowly becoming more
sophisticated. The Argon Parser converts the Argon language into a somewhat Abstract Syntax Tree. The Argon Compiler
then converts this into a 3 address code / SSA format intermediate representation ( IR ). The compiler has several passes 
which analyze the IR by first converting the IR into a Basic Block based Flow Graph. This graph is then acted on by several different
optimizers, and finally is used to generate the Virtual Machine Code. The machine instruction format is fairly typical of
a modern CISC machine with 32 general purpose registers and 32 floating point registers. Instructions typically involve
three registers or two registers and an immediate value, addressing is direct, indirect, and register indirect.

Argon natively supports Boolean,Integer, Byte, Float, BitMap, Map, Vector and String types. It only supports 32 bit 
floating point representation however it allows for integer representations of up to 60 bits. 
The top 4 bits of any value is a tag that the VM uses to know how to handle values. Garbage collection is built in to 
Argon with a Generational Copying Garbage Collector I developed. The VM memory consists of both a static data segment
and two object spaces, objects are allocated in one space, and when memory is low reachable objects are copied to the
second space, leaving behind non referenced objects. The stack, data segment, and VM registers are all scavenged for
object references when a garbage collection ( or flip ) takes place. The VM is tweaked
for some of the demanding operations Argon needs, such as multimethod dispatch and nextMethod invocation in multimethods, 
object allocation, garbage collection and access to root objects during garbage collection.

Every bit of Argon code has to be contained in either an Executable module or a Library module. An Executable can import but 
not export symbols, whereas a Library can do both. Resolution of symbols is at runtime, and the compiler can produce either
an .argon.bin package which can be executed directly by the VM once it's imports have been resolved, or an .argon.lib package
which can be loaded by the to resolve symbols.

```
//
// A sample executable file for Argon
//
executable GoFishing
    {
    constant kAverageWhaleWeightInKilograms = 4_000_000
    
    traits AquaticAnimal<Type>
        {
        name::String
        latinName::String
        averageWeightInKilograms::Integer
        preferredArea::Symbol
        breathesAir::Boolean = #false
        isMammal = #false
        isEdible::Type
        }

    traits Cetacean::AquaticAnimal<Type=Boolean>
        {
        sucklesYoung::AquaticAnimal.Type
        made()
            {
            this.breathesAir = #true
            this.isMammal = #true
            nextMethod()
            }
        }

    traits Fish::AquaticAnimal<Type=Symbol>
        {
        }

    traits Shark::Fish
        {
        }

    method swimAround(animal::Cetacean,value::Integer) -> Integer
        {
        return(value)
        }

    method swimAround(animal::Fish,value::Integer) -> Integer
        {
        return(value)
        }

    method print(anything::Behaviour)
        {
        }

    entrypoint()
        {
        let randomVariationInWeight = random(Integer,10,1000)
        let newWeight = kAverageWhaleWeightInKilograms + (randomVariationInWeight * 10 + 100) / 9
        let aSymbol = #symbol1
        let value = 0
        let vector = make(Vector,200)
        for index in (from 1,to 20,by 1)
            {
            let someValue = index * 12
            print(someValue)
            }
        switch(aSymbol)
            {
            case #symbol1:
                value = 1
            case #symbol2:
                value = 2
            case #symbol3:
                value = 3
            case #symbol4:
                value = 4
            otherwise:
                value = 9
            }
        if randomVariationInWeight > 200
            {
            randomVariationInWeight = 200
            }
        else
            {
            randomVariationInWeight = randomVariationInWeight +7
            }
        newWeight = newWeight + 200
        let whale = make(Cetacean)
        let fish = make(Fish)
        vector[0] = fish
        vector[1] = whale
        print(vector[1])
        swimAround(whale,47)
        swimAround(fish,19)
        let someIndex = 0
        while someIndex < 200
            {
            someIndex = someIndex + 12
            }
        print(someIndex)
        }
    }
```
