# clap_delphi

>!!! Attention !!!
>
> The bindings are still INCOMPLETE. Please be patient until they become usable.

**CLAP** header bindings for the **Delphi** programming language. <br/>
Providing a direct opportunity for programming *"clever audio"* daw plugins.

These headers result from an indirect translation of the code from [this](https://github.com/OralLabs/clap) repository. While copying the module structure, instead of using C-style *include* files, all definitions were placed into modular implementations (inside **UNITS**). This method minimizes redundancy and errors that could happen while including header files (multiple times) into source code. Additionally, dotted unit names were used for underlining the hierarchy.

Under the **src** path, all binding modules can be found.
For realizing a proper initial integration, an example project is stored inside the **example** folder.

This code is completely free to use (*OPEN SOURCE*), even **without adding license and ownership for (a finally unnecessary) copyright.