# FindMeFoodTruck

A web page to locate the nearest food truck to you. It uses the location
your browser reports as the start, and only considers food trucks in
San Franscisco as viable destinations.

# Building and Depolying

This requires [elixir](http://elixir-lang.org).

Assemble the application using `mix release`. There is no difference mix
environments.

Finally, run the system using _build/prod/rel/fmft/fmft start

# That didn't work

It's possible I haven't completed the full ambitious project. Below will be the
steps to run what has actually been accomplished.

# Assessment Notes

Normally this section wouldn't exist. However, due to the nature of the
project, it makes sense to have a central place to gather some thoughts as they
occur, or explain facets that don't fit neatly elsewhere.

## The Project Idea

A user can browse to the website. The site shows a list of the food trucks in
order of distance, nearest being first. The user can add filter, narrowing the
result list.

I don't expect I'll get all the way there. The primary focus will be on Building
the functional parts and see how far I get.

I have decided to build this in Elixir despite being far more familiar with
Erlang's syntax. My reason is 2-fold: I want to shore up my elixir experience,
and I want to show what I can do in a Elixir environment as that is job I'm
aiming for.

## Phase one: Just read the file.