## -- PRIVATE FUNCTIONS BELOW HERE ------------------------------------------------------------------------------ #
function _jld2(path::String)::Dict{String,Any}
    # Prefer explicit JLD2 loader when possible so custom extensions (e.g. .kgm49)
    # that contain JLD2-formatted bytes can still be read.
    if isfile(path)
        try
            return JLD2.load(path)
        catch
            return FileIO.load(path)
        end
    end

    # try alternate extension .kgm49 if original path used .jld2
    alt = replace(path, r"\.jld2$" => ".kgm49")
    if isfile(alt)
        return JLD2.load(alt)
    end

    # final fallback: let FileIO provide the error for the original path
    return FileIO.load(path)
end
# -- PRIVATE FUNCTIONS ABOVE HERE ------------------------------------------------------------------------------ #

# -- PUBLIC FUNCTIONS BELOW HERE ------------------------------------------------------------------------------- #

"""
    MyTestingMarketDataSet() -> Dict{String, DataFrame}

Load the components of the SP500 Daily open, high, low, close (OHLC) dataset as a dictionary of DataFrames.
This data was provided by [Polygon.io](https://polygon.io/) and covers the period from January 3, 2025, to the current date (it is updated periodically).

"""
MyTestingMarketDataSet() = _jld2(joinpath(_PATH_TO_DATA, "SP500-Daily-OHLC-1-3-2025-to-11-18-2025.jld2"));

"""
    MyTrainingMarketDataSet() -> Dict{String, DataFrame}

Load the components of the SP500 Daily open, high, low, close (OHLC) dataset as a dictionary of DataFrames.
This data was provided by [Polygon.io](https://polygon.io/) and covers the period from January 3, 2014, to December 31, 2024.

"""
MyTrainingMarketDataSet() = _jld2(joinpath(_PATH_TO_DATA, "SP500-Daily-OHLC-1-3-2014-to-12-31-2024.jld2"));

"""
    MyTickerPickerBanditModelResults() -> Dict{String, Any}

Load the ticker-picker bandit model results computed in the `Setup-L14a-Example-RiskAware-BBBP-Ticker-Picker-Fall-2025.ipynb` notebook.
"""
function MyTickerPickerBanditModelResults(;mood::Symbol = :neutral)::Dict{String, Any}
    valid = Set([:optimistic, :neutral, :pessimistic])
    if !(mood in valid)
        error("Invalid mood specified: $mood. Valid options are :optimistic, :neutral, :pessimistic.")
    end

    mood_name = uppercasefirst(String(mood))
    base = joinpath(_PATH_TO_DATA, "Ticker-Picker-Preferences-$(mood_name)-Fall-2025")

    # Try .kgm49 first (user requested custom extension), then .jld2
    p_kgm = base * ".kgm49"
    p_jld2 = base * ".jld2"

    if isfile(p_kgm)
        return _jld2(p_kgm)
    elseif isfile(p_jld2)
        return _jld2(p_jld2)
    else
        # Provide a clear error message listing attempted paths
        error("No preference file found for mood=$(mood). Tried: $(p_kgm) and $(p_jld2)")
    end
end
# -- PUBLIC FUNCTIONS ABOVE HERE ------------------------------------------------------------------------------ #