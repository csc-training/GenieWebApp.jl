module WebAppDB

using Genie, Logging, LoggingExtras

function main()
  Base.eval(Main, :(const UserApp = WebAppDB))

  Genie.genie(; context = @__MODULE__)

  Base.eval(Main, :(const Genie = WebAppDB.Genie))
  Base.eval(Main, :(using Genie))
end

end
