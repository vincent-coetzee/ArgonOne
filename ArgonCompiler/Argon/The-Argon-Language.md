#  The Argon Language

There are 7 primitive types in Argon, these are

digits ::= 0 1 2 3 4 5 6 7 8 9
byte ::= $ digits

Method directives appear before a method declaration and have one of four values

* inline, this requests that the method be inlined if possiblle
* system, this marks the method as a system method, this may only be used in the standard libraries and in library modules
* dynamic, the implementation of this method will be provided at runtume
* static, use static and not generic dispatch to dispatch this method, can only be done on singleton methods

Use a @ following with parentheses containing the directives

directive ::= inline, system, dynamic, static
directives ::= directive direction directive +
directiveAnnotation ::= @( directives)

Example:

    @(inline,static)
    @(static,dynamic,system)
    @(inline,system)

Method invocation statements. A normal method invocation is dyanmically dispatched in a generic fashion,
whereby the traits of each argument are used to find the most specific method and then that method is
called. Inside of a generic method, it is possible to call the next most specific method. In this case invoking the
method *nextMethod* with the same arguments that were passed to the enclosing method will cause the
system to dispatch the and call the next most specific methods.

Arguments to a method are always named, and the names of the arguments of the first implementation 
of a generic method define the names that *ALL* instances of the generic method *MUST* use.

Example:

The first instance of the swimAround method is defined as follows

    method swimAround(fishType::AquaticAnimal,preferredDepth::Integer) -> Boolean
    
That means that all susequent instantiations of swimAround must use the arguments names fishType and preferredDepth.
If you wish to not use an argument name for a certain argument, then prefix the name with a  #, like so

    method swimAround(#fishType::AquaticAnimal,preferredDepth::Integer) -> Boolean
    
So wherease the first example would have to be invoked as

    let whale = make(Cetacean)
    swimAround(fishType::whale,preferredDepth::1000)
    
The second would be invoked as

    swimAround(whale,preferredDepth::1000)
