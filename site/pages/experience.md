For more experience, see my [Resume](/Resume.pdf). Here is a detailed timeline of the important parts:

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

### NuPRL (Ř)

I worked at [Northeastern's Programming Research Laboratory (NuPRL)](http://prl.ccs.neu.edu/) on an R JIT compiler called [Ř](https://github.com/reactorlabs/rir), with a large team. My specific contributions include:

- Creating micro-benchmarks for individual components (e.g. while loops), and profiling them
- "Simple ranges": an optimization pass which compiles `for (i in a:b) ...` into a C-style while loop, avoiding range allocation
- Improved type inference and "type assertions", which validate that the inferred types are actually correct in debug mode
- Bytecode serialization / deserialization, so we don't need to recompile the same function across sessions
- Experimented with manually adding extra annotations to functions to improve analysis / optimization, and checking these annotations at runtime
- Added a configurable assertion that a function won't modify variables outside of its lexical scope. In the R REPL, if a variable gets modified during execution of said function, the interpreter will signal an error and abort the current command.
- Attempt using Software Transactional Memory to speculatively "force" pure lazy values: if the value triggers a side-effect during evaluation, the side effect will not occur and state will be reverted to before. If the transaction succeeds, we know that the value does not trigger side-effects, which greatly helps analysis.

We published one paper, **[R Melts Brains](https://arxiv.org/abs/1907.05118)** (SPLASH 2019). It describes the challenges of implementing a JIT compiler with static analysis in R, mainly because of laziness and first-class environments.

## NextDroid Internship

[NextDroid](https://nextdroid.com/) provides ground-truth verification for self-driving cars using LIDAR: basically the company puts higher-powered sensors on top of the car's sensors to prove that the car sensors work properly. The sensors we used are [VeloDyne](https://velodynelidar.com/). I did *not* work on the ground-truth, however I worked on the website (TypeScript/JavaScript) and camera driver (C++).

For the website, in particular I helped create a camera feed which stays in sync with the timeline. The "timeline" shows the car driving along a point-cloud, and the user can jump to arbitrary time points, or speed/slow playback. I had to find a way to fetch and play the video recorded from the camera so that it loads quickly when jumping to a time point, and didn't stutter when being played faster or slower. I implemented this by breaking the video into many images, and creating a smart heurstic for which images to fetch and when to cancel image fetch requests, so that the video can play and buffer accordingly.

## PRL@PRG Internship (Ř): January 2020 - May 2020 in Prague

I was a assistant researcher at the [<PRL@PRG>](https://prl-prg.github.io/) lab in Prague, supervised by Jan Vitek. I helped write another paper **[Contextual Dispatch for Function Specialization](http://janvitek.org/pubs/oopsla20-cd.pdf)** (SPLASH 2020), and developed a profiler for Ř. After the paper was published, I continued to work on the profiler and added an event logger.

The profiler and event logger measure: number of call sites per function, number of times each function was executed at each call site, total execution time of the function, number of versions of each function (we compile multiple versions for different optimization contexts), time spent in each compilation pass for each version, number of times each function was deoptimized.

## Purdue Graduate School

Currently, I am attending Purdue University of Indiana. As of spring 2023 I will have taken:

- **CS510 Software Engineering:** Software engineering focused on machine learning to automate bug detection
- **CS584 Theory:** Turing machines, complexity classes, and basic quantum computing
- **CS503 Operating Systems:** Low-level OS knowledge and work on the [xinu](https://xinu.cs.purdue.edu/) teaching OS
- **CS578 Machine Learning:** Machine learning basics, including decision trees, linear/logistic regression, basic neural networks (autoencoder), and SVMs
- **CS592 Software Verification:** Seminar-style course where each student gave 2 presentations on papers involving software verification. My presentations were on sel4 ([original](http://web1.cs.columbia.edu/~junfeng/09fa-e6998/papers/sel4.pdf), [presentation](https://docs.google.com/presentation/d/1Cgm3cl_Gif4f-0eH8EJ5QqVfMcyiubmEbs0kUnBK8Vo/view
  )) and Armada ([original](https://www.microsoft.com/en-us/research/publication/armada-low-effort-verification-of-high-performance-concurrent-programs/), [presentation](https://docs.google.com/presentation/d/1maUgRxwgRZFYOwerFPz93Cy9lTQOTWJFiLqqCIOmdZM/view))
- **CS502 Compilers:** A class on compiler steps and algorithms (lexing, parsing, type checking, IR generation, static analyses, optimization, register allocation, etc.)
- **CS592 Intepretability of ML:** Another seminar-style course where each student presented a paper involving interpretability of ML, and then created their own ML project. My presentation was on *Evaluating the Interpretability of Generative Models by Interactive Reconstruction* ([paper](https://arxiv.org/pdf/2102.01264), [presentation](https://docs.google.com/presentation/d/1NcmwGHCLBI81ssHzHllBpjRU_mrTM_xVs2A5dl49ALY/view)), and my project was on a modified implementation of AlphaZero which works on more general games ([presentation](https://docs.google.com/presentation/d/1ktt_2jE_DIQh3v-QaaWQfa3SbtFmu-c-LJC9pKUUkX8/view), [repo](https://github.com/Jakobeha/cge-ai), [a presentation on AlphaGo and its derivatives](https://docs.google.com/presentation/d/134bZdCOJR_RqtQYQ0bZaiAQbjQEjWe5V-gmtI5EBvPg/view))
- **CS536 Distributed Networking (current):** A course on the evolution of networking (bridges, switches, OpenFlow, different networking layouts) where we build and simulate various device implementations using [mininet](http://mininet.org/). Focuses on performance challenges and improvements, as efficiency is the main networking challenge today
- **CS565 Programming Languages (current):** A course on programming language verification using [coq](https://coq.inria.fr/) and [dafny](https://www.microsoft.com/en-us/research/project/dafny-a-language-and-program-verifier-for-functional-correctness/)
