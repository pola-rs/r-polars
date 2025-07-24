# Warn if daemons already exist when registering mirai serialization configs

    Code
      register_mirai_serial()
    Condition <rlang_warning>
      Warning:
      ! Automatically registered mirai serialization configs by polars does not affect existing daemons. i To apply the configs, recreating daemons is needed.

