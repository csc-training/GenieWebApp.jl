module GenieWebApp

using Genie, Logging, LoggingExtras

function main()
  Base.eval(Main, :(const UserApp = GenieWebApp))

  Genie.genie(; context = @__MODULE__)

  Base.eval(Main, :(const Genie = GenieWebApp.Genie))
  Base.eval(Main, :(using Genie))
end

end
