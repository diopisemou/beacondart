fun ModuleDependency.withoutJna(): ModuleDependency = apply {
    exclude(group = "net.java.dev.jna")
}