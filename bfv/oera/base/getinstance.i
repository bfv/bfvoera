
/* returns correctly typed instance of &class */
method public static {&class} GetInstance():
  return cast(bfv.oera.service.ServiceManager:StartService("{&class}"), {&class}).
end method.