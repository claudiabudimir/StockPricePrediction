module GroundbreakingDiscovery

using AlphaVantage
using DataFrames
using Dates
using Plots
using LinearAlgebra
using Statistics
using Distributions
using CSV
using Printf

export getDataFromDatabase
export displayHistoricalDataTrends
export runMonteCarloSimulation
export printMonteCarloSimulationResult
export displayMonteCarloSimulationResult

struct SimulationResult
    avgDailyReturn::Float64
    varDailyReturn::Float64
    stdDailyReturn::Float64

    drift::Float64
    yesterdaysPrice::Float64

    minPredictedPrices::Float64
    avgPredictedPrices::Float64
    maxPredictedPrices::Float64

    predictedPrices::Vector{Float64}
end

function processData(data::DataFrame)::DataFrame
    data[!, :timestamp] = Dates.Date.(data[!, :timestamp]);
    data[!, :open] = Float64.(data[!, :open])
    data[!, :high] = Float64.(data[!, :high])
    data[!, :low] = Float64.(data[!, :low])
    data[!, :close] = Float64.(data[!, :close])

    return data
end

function displayHistoricalDataTrends(data::DataFrame)
    x = plot(data[!, :timestamp], data[!, :open], label="Open")
    plot!(data[!, :timestamp], data[!, :high], label="High")
    plot!(data[!, :timestamp], data[!, :low], label="Low")
    plot!(data[!, :timestamp], data[!, :close], label="Close")
    #display(x)
end

"""
    percentageChange(input::AbstractVector{<:Number})

This function is used to calculate the percentage change between two values in the input vector, where the percentage change is calculated using the formula: ((val2 - val1) / val1) * 100 = ((val2/val1) - 1) * 100.

Arguments:
- input::AbstractVector{<:Number}: Input vector containing numerical values

"""
function percentageChange(input::AbstractVector{<:Number})
    res = @view(input[2:end]) ./ @view(input[1:end-1]) .- 1
    return res
end

"""
    runMonteCarloSimulation(data::DataFrame, nbOfPredictions::Int)

This function runs a Monte Carlo simulation to model future stock prices based on historical data.

Formula based on Brownian motion:
tomorrowsPrice = yesterdaysPrice * e^(drift + randomVariable)
drift = avgDailyReturn - varDailyReturn / 2
randomVariable = stdDailyReturn * NORMSINV(RAND())

Arguments:
- data::DataFrame: Historical stock price data
- nbOfPredictions::Int: Number of predictions to generate

Returns:
- SimulationResult: Result of the Monte Carlo simulation
"""
function runMonteCarloSimulation(data::DataFrame, nbOfPredictions::Int)::SimulationResult
    dailyReturn = log.(1 .+ percentageChange(data[!, :close]))
    avgDailyReturn = Statistics.mean(dailyReturn)
    varDailyReturn = Statistics.var(dailyReturn)
    stdDailyReturn = Statistics.std(dailyReturn)
    drift = avgDailyReturn .- (varDailyReturn / 2.0)

    x = rand(nbOfPredictions)
    randomVariable = [stdDailyReturn] .* quantile.(Normal(), x)

    magicEs = exp.([drift] .+ randomVariable)
    yesterdaysPrice = data[!, :close][length(data[!, :close])]
    predictedPrices = [yesterdaysPrice * magicE for magicE in magicEs]

    minPredictedPrices = minimum(predictedPrices)
    maxPredictedPrices = maximum(predictedPrices)
    avgPredictedPrices = Statistics.mean(predictedPrices)

    return SimulationResult(avgDailyReturn, varDailyReturn, stdDailyReturn,
                            drift, yesterdaysPrice,
                            minPredictedPrices, avgPredictedPrices, maxPredictedPrices,
                            predictedPrices)
end

function printMonteCarloSimulationResult(result::SimulationResult)
    parameters = ["DAILY_RETURN_AVERAGE", "DAILY_RETURN_VARIANCE", "DAILY_RETURN_DEVIATION",
                  "DRIFT", "YESTERSDAY_PRICE", "MIM_PREDICTED_PRICE",
                  "AVERAGE_PREDICTED_PRICE", "MAX_PREDICTED_PRICE"]
    values = [result.avgDailyReturn, result.varDailyReturn, result.stdDailyReturn,
              result.drift, result.yesterdaysPrice, result.minPredictedPrices,
              result.avgPredictedPrices, result.maxPredictedPrices]

    @printf("%-25s %-10s\n", "Parameter", "Value")
    for (p, v) in zip(parameters, values)
        @printf("%-25s %-10.6f\n", p, v)
    end
end

function displayMonteCarloSimulationResult(predictedPrices::Vector{Float64})
    h = histogram(predictedPrices, label="TommorowsPricePrediction")
    #display(h)
end

function getDataFromDatabase(stockName::String, includeAllHistoricalData::Bool=false)::DataFrame
    # Import data from my personal local storage
    if includeAllHistoricalData == true
        dataFilename = stockName*"_full.csv"
    else
        dataFilename = stockName*".csv"
    end

    data = DataFrame(CSV.File("data/"*dataFilename))

    # Convert dates to Date type and stock values to Floats
    processedData = processData(data)
    return processedData
end

function runApp(stockName::String, includeAllHistoricalData::Bool=false)
    # Get data
    processedData = getDataFromDatabase(stockName, includeAllHistoricalData)

    # Display data
    displayHistoricalDataTrends(processedData)

    # Run Monte Carlo simulation
    result = runMonteCarloSimulation(processedData, 1000)

    # Print Monte Carlo simulation resuls
    printMonteCarloSimulationResult(result)

    # Display Monte Carlo simulation resuls
    displayMonteCarloSimulationResult(result.predictedPrices)
end

# Example of running the app
# runApp("NFLX")

end # module GroundbreakingDiscovery
