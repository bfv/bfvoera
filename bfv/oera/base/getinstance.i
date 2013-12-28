
/* returns correctly typed instance of &class */
method public static {&class} GetInstance():
  return cast(OERA.service.ServiceManager:StartService("{&class}"), {&class}).
end method.