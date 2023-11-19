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
    createnotebooks(dir; args...)

Create notebooks for each `.jl` script found at `dir`.
"""
function createnotebooks(path_from::String, path_to::String; args...)
    # get input and output paths
    jls = filter(
        x -> occursin(r"/[0-9]+-.*\.jl$|/index.jl$", x),
        readdir(path_from, join = true)
    )
    ipynbs = replace.(replace.(jls, path_from => path_to), ".jl" => ".ipynb")

    # create notebooks
    rm(path_to, recursive = true, force = true)
    Literate.notebook.(jls, path_to; args...)
end
"""
    createmarkdowns(path_from, path_to, repo_path)

Create markdown files for each `.jl` script found at `path_from` and save in `path_to`.
"""

function createmarkdowns(path_from, path_to, repo_path; kwargs...)
    # get input paths
    jls = filter(
        x -> occursin(r"/[0-9]+-.*\.jl$|/index.jl$", x),
        readdir(path_from, join = true)
    )

    # create page
    rm(path_to, recursive = true, force = true)
    Literate.markdown.(jls, path_to, execute = false, documenter = true,
        repo_root_url = repo_path, credit = false)

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

export createscripts
export createnotebooks
export createmarkdowns
export copyproject

end # module ComposerTools
