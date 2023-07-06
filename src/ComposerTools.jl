"""
ComposerTools.jl provides functions to merge `.jl` scripts and create notebooks for merged
scripts. The main use is to create notebooks and webpages from pre-organized files by
directories using `Literate.jl` and `Documenter.jl` in a reproducible way.
"""
module ComposerTools

import Pkg
using Literate

"""
    createscripts(path_from, path_to)

Read directories inside `path_from` path, merge files inside each directory and save merged
files at `path_to` directory.
"""
function createscripts(path_from::String, path_to::String; remove = false)
    # create output directory
    if remove
        rm(path_to, recursive = true, force = true)
    end
    mkpath(path_to)

    # get input and output paths
    folders = readdir(path_from) |>
        z -> filter(x -> occursin(r"[0-9]+-.*$", x), z)
    path_inputs = joinpath.(path_from, folders)
    path_outputs = joinpath.(path_to, folders .* ".jl")

    # create joined scripts
    mergefolder.(path_inputs, path_outputs)

    return nothing
end

"""
Merge files inside `folder` path and save in `output` file.
"""
function mergefolder(folder::String, output::String)
    input = filter(x -> occursin(r"^[0-9]+.*\.jl$", x), readdir(folder)) |>
        x -> joinpath.(folder, x)
    mergefiles(input, output)
end

"""
Merge `input` files and save in `output` file.
"""
function mergefiles(inputs::AbstractVector{String}, output::String)
    text = vcat(map(readlines, inputs)...)
    open(output,"w") do file
        for line in text
            println(file, line)
        end
    end
end

"""
    copyproject()

Copy "Manifest.toml" and "Project.toml" from active project.
"""
function copyproject()
    path_from = dirname(Pkg.project().path)
    map(["Manifest.toml", "Project.toml"]) do x
        cp(joinpath(path_from, x), x, force = true)
    end
end


# function createnotebooks(folder = "scripts")
#     # get input and output paths
#     jls = filter(
#         x -> occursin(r"/[0-9]+-.*\.jl$|/index.jl$", x),
#         readdir(folder, join = true)
#     )
#     ipynbs = replace.(replace.(jls, folder => "notebooks"), ".jl" => ".ipynb")
#
#     # create notebooks
#     rm("notebooks", recursive = true, force = true)
#     Literate.notebook.(jls, "notebooks", execute = true)
# end

# # Create markdown files
# repo_path = "https://github.com/ErickChacon/01-computational-statistics-julia/blob/main"
# rm(joinpath("docs", "src"), recursive = true, force = true)
# Literate.markdown.(jls, joinpath("docs", "src"), execute = true, documenter = true,
#     repo_root_url = repo_path, credit = false)

export createscripts
export copyproject

end # module ComposerTools
