### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 72fbabd6-7e14-11ee-2cea-73adadc7af10
begin
using Pkg
using PlutoUI
function ingredients(path::String)
	# this is from the Julia source code (evalfile in base/loading.jl)
	# but with the modification that it returns the module instead of the last object
	name = Symbol(basename(path))
	m = Module(name)
	Core.eval(m,
		Expr(:toplevel,
			 :(eval(x) = $(Expr(:core, :eval))($name, x)),
			 :(include(x) = $(Expr(:top, :include))($name, x)),
			 :(include(mapexpr::Function, x) = $(Expr(:top, :include))(mapexpr, $name, x)),
			 :(include($path))))
	m
end
MCSIM = ingredients("src/GroundbreakingDiscovery.jl").GroundbreakingDiscovery
end

# ╔═╡ a071f573-8740-4ec0-92a1-d952317600b4
Pkg.activate("Project.toml")

# ╔═╡ 88b461ab-d093-444d-9219-ae4470cc0188
md"# Another day, different stock prices"

# ╔═╡ e952ad03-97ab-4c57-aaa8-7d2bb2d466d1
md"### Input stock data specifications"

# ╔═╡ f188e0dd-4b38-444a-ad66-d4e9e8c49a3a
begin
y = @bind stock Select(["VOO", "SPY", "NFLX", "TSL"])

md""" **Choose the stock for which you want to predict tomorrow's price**

Possible options:

		    VOO = Vanguard S&P 500 ETF

		    SPY = SPDR S&P 500 ETF Trust

		    NFLX = Netflix Inc

            TSL = Tesla ETF

   **Stock:** $(y)"""
end

# ╔═╡ e15ec9cf-6478-473c-830a-fff4c15f2c49
begin
dd = @bind dataDebit Select(["RECENT", "ALL"])

md""" **Choose the amount of data to be included in the simulation**

Possible options:

		    RECENT = last 5 months or less

		    ALL = all data available 

   **Data size:** $(dd)"""
end

# ╔═╡ 0b5d4675-5582-4979-958f-848bd6b0cad2
begin
	includeAll = false
	if dataDebit == "ALL"
		includeAll = true
		println("You chose to include all data available")
	else
		println("Only recent data will be used")
	end
end

# ╔═╡ afe36864-f494-4125-972b-30322dadbee5
md"#### Historical prices overview"

# ╔═╡ ad9bddc0-8edf-487f-939c-7705e59b8a7b
begin
	# Get data
	processedData = MCSIM.getDataFromDatabase(stock, includeAll)

	# Display data
	MCSIM.displayHistoricalDataTrends(processedData)
end

# ╔═╡ e20f00ad-2d83-4769-be37-89d1abd0cc41
md"#### Monte Carlo Simulation"

# ╔═╡ 16768bbf-1c51-42bf-8012-a112d5da2507
begin
nbP = @bind numberOfPredictions TextField(default="1000")

md"
   **NumberOfPredictionsForMonteCarloSimulation:** $(nbP)"
end

# ╔═╡ 9fd9791b-dab4-4805-9deb-2fa7cab8547d
begin
	# Run Monte Carlo simulation
	result = MCSIM.runMonteCarloSimulation(processedData, parse(Int64,numberOfPredictions))
end

# ╔═╡ 1d8f4c89-b834-4c7d-a6cc-ff6ac67f9465
begin
    # Print Monte Carlo simulation resuls
    MCSIM.printMonteCarloSimulationResult(result)
end

# ╔═╡ 78b0e266-ec63-441d-9608-cade602bdca4
begin
    # Display Monte Carlo simulation resuls
    MCSIM.displayMonteCarloSimulationResult(result.predictedPrices)
end

# ╔═╡ Cell order:
# ╟─88b461ab-d093-444d-9219-ae4470cc0188
# ╟─72fbabd6-7e14-11ee-2cea-73adadc7af10
# ╟─a071f573-8740-4ec0-92a1-d952317600b4
# ╟─e952ad03-97ab-4c57-aaa8-7d2bb2d466d1
# ╟─f188e0dd-4b38-444a-ad66-d4e9e8c49a3a
# ╟─e15ec9cf-6478-473c-830a-fff4c15f2c49
# ╟─0b5d4675-5582-4979-958f-848bd6b0cad2
# ╟─afe36864-f494-4125-972b-30322dadbee5
# ╟─ad9bddc0-8edf-487f-939c-7705e59b8a7b
# ╟─e20f00ad-2d83-4769-be37-89d1abd0cc41
# ╟─16768bbf-1c51-42bf-8012-a112d5da2507
# ╟─9fd9791b-dab4-4805-9deb-2fa7cab8547d
# ╟─1d8f4c89-b834-4c7d-a6cc-ff6ac67f9465
# ╟─78b0e266-ec63-441d-9608-cade602bdca4
