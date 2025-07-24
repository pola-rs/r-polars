# Warn if daemons already exist when registering mirai serialization configs

    Code
      register_mirai_serial()
    Message <rlang_message>
      i The polars package was loaded after mirai daemons were already created. i To apply the serialization config registered by polars, recreate daemons. * Run `mirai::daemons(0)` to reset daemon connections, then recreate daemons with `mirai::daemons()`. i Suppress this message by loading polars before creating daemons (or loading mirai).

