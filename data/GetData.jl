using AlphaVantage, DataFrames, CSV

client = AlphaVantage.GLOBAL[]
client.key = "BRNW01K2DXJAE4JI"

stockName = "VOO"

# When outputsize is 'full' one gets the entire historical data
# if missing one gets last couple of months of data
result = time_series_daily(stockName, datatype="csv")
# result = time_series_daily(stockName, outputsize="full", datatype="csv");

# Convert to a DataFrame so it can be exported as a CSV
data = DataFrame(result[1], :auto)
# Add column names
data = rename(data, Symbol.(vcat(result[2]...)))

CSV.write(stockName * ".csv", data)
#CSV.write(stockName * "_full.csv", data)