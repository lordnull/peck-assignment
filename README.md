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

I was not able to complete the full ambitious project in just 3 hours. I
did not expect to. However, I did get something done.

After cloning the git repo, `cd` into the project directory. Run `iex -S mix`.

At the prompt, run `{:ok, p} = Fmft.Datastore.start_link()`.

Finally, run `Fmft.Datastore.find_trucks(p, 1.0, 1.0)`.

This will spew out a long list of `{locationid => truck_data}` entries sorted
by distance from the latitude/longitude of 1.0, 1.0. If you know your actual
position on earth, you can imput that in instead of the 1.0,1.0.

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

## Where I got

An agent module that is able to inport the contents of the provided CSV file, keep it
in memory, and answer the question "what's the closest truck". This would be the core
of the web app, thus a logical place to start.

There are many things I would improve about the project.
1. Instead of storing a basic string -> string map of the imported data, I would
   send it through sanitation to ensure values make sense. Things like ensureing
   the latitude and longitude are actual numbers.
2. Storing the data in a `protected` ets table. This way, the datastore process
   need not block itself and others asking to read the data. This would also
   push the sort onto the requester, making for a faster overall system. I did not
   do this as I'm not yet familiar enough with how Elixir interacts with ets to feel
   confident I could get that far in 3 hours.
3. Improved dialyzer typing. The functions are not spec'ed, and that bothers me. At
   least they are documented.
