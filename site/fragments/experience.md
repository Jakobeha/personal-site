## Prior September 2017

I started programming as a hobby working on side projects. In high school I took AP Computer Science A + AP Computer Science Principles.

## Northeastern University: September 2017 - January 2020

I graduated with a Bachelor's degree in Computer Science and a GPA of 3.877 / 4. Notable classes:

- **CS2500 Fundamentals of Computer Science 1**: Writing simple functional programs in Racket
- **CS4992 "Hack Your Own Language"**: Build a DSL in Racket (my group built a JavaDoc-like extension, which parses documentation into Scribble and checks examples)
- **CS2800 Logic and Computation**: Basic theorem proving with ACL2s
- **CS4800 Algorithms and Data**: Basic algorithms
- **CS3650 Systems**: Low-level systems programming (e.g. assembly) and optimization
- **CS4550 Web Development**: Fast overview of client (jQuery, React, Angular, Elm), server (Java + Spring Boot, node.js express, Elixir + Phoenix), and database (MySQL + JPA, PostgreSQL + Ecto, MongoDB) technologies
- **CS4992 Directed Study**: Read papers on abstract interpretation, control flow analysis in Scheme, and STM. Wrote summaries / implemented the algorithms
- **ENGW3301 Advanced Writing**: Technical writing to different audiences (e.g. research paper, portfolio)
- **CS4910 Verified Compilers**: Build Toy languages / compiler passes in Coq, and prove that passes preserve semantics via simulation relations
- **CS4500 Software Development**: Develop an application with a team in an industry-like scenario, writing design documents and leading / paneling code walks
- **CS4200 Networks and Distributed Systems**: High-level overview of how networks and distributed systems work: the ISO-OSI stack, and examples of layer implementations / protocols / distributed systems used in practice (e.g. Ethernet, TCP, Paxos, HTTP)
- **CS4410 Compilers**: Followed *[Modern Compiler Implementation in ML](https://www.amazon.com/Modern-Compiler-Implementation-Andrew-Appel-ebook/dp/B00D2WQAE8)* and built a Tiger compiler to MIPS: lexer, parser, static semantics, IR generator, assembler, liveness / dataflow analysis, register allocation with coalescing

I also attended hackathons and clubs, and presented a poster at [RISE](https://www.northeastern.edu/rise/) (a small University expo) on a side project: [**TreeScript**](https://github.com/jakobeha/treescript), a programming language that rewrites syntax of other languages.

### NuPRL

I worked at [Northeastern's Programming Research Laboratory (NuPRL)](http://prl.ccs.neu.edu/) on an R JIT compiler called [Ř](https://github.com/reactorlabs/rir), with a large team. My specific contributions include:

- Creating micro-benchmarks for individual components (e.g. while loops), and profiling them
- "Simple ranges": an optimization pass which compiles `for (i in a:b) ...` into a C-style while loop, avoiding range allocation
- Improved type inference and "type assertions", which validate that the inferred types are actually correct in debug mode
- Bytecode serialization / deserialization, so we don't need to recompile the same function across sessions
- Experimented with manually adding extra annotations to functions to improve analysis / optimization, and checking these annotations at runtime
- Added a configurable assertion that a function won't modify variables outside of its lexical scope. In the R REPL, if a variable gets modified during execution of said function, the interpreter will signal an error and abort the current command.

We published one paper, **[R Melts Brains](https://arxiv.org/abs/1907.05118)** (SPLASH 2019). It describes the challenges of implementing a JIT compiler with static analysis in R, mainly because of laziness and first-class environments.

## PRL@PRG Internship: January 2020 - May 2020 in Prague, June 2020 - July 2020 at home

I was a assistant researcher at the [<PRL@PRG>](https://prl-prg.github.io/) lab in Prague, supervised by Jan Vitek. I helped write the paper **[Contextual Dispatch for Function Specialization](http://janvitek.org/pubs/oopsla20-cd.pdf)** (SPLASH 2020), and developed a profiler for Ř. After the paper was published, I continued to work on the profiler and added an event logger. The profiler and event logger measure: number of call sites per function, number of times each function was executed at each call site, total execution time of the function, number of versions of each function (we compile multiple versions for different optimization contexts), time spent in each compilation pass for each version, number of times each function was deoptimized.

## Purdue Graduate School

Currently, I am attending Purdue University of Indiana. As of spring 2021 I have taken:

- **CS510 Software Engineering:** Software engineering focused on machine learning to automate bug detection
- **CS584 Theory:** Turing machines, complexity classes, and basic quantum computing
