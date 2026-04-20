---
title: In the loop, on the loop
date: 2026-04-06
excerpt: The mental shift from writing code with an agent to directing one. Why my opinions kept evaporating between sessions, and what that actually costs.
---

Karpathy called the era we're leaving "vibe coding". The community has mostly moved on to something with a better name. The version I care about is this: the shift from writing code _with_ an agent to directing one.

If you've been using Claude Code or Cursor in earnest for the last year, you've probably felt this shift. I certainly did, mostly without noticing, and then one afternoon I realised I'd spent three hours not typing code at all. I'd been reading diffs, redirecting plans, telling the loop "no, not like that, like this". That's when the phrase _on the loop_ started to make sense. You're not in the loop any more, doing each iteration yourself. You're above it, setting up the conditions for it to do its thing.

## What "on the loop" actually demands

Here's the uncomfortable bit. On-the-loop work isn't a promotion. It's a different job with different requirements, and the one that caught me by surprise is how much it depends on _pre-committed opinions_.

When I was in the loop, my opinions could live in my head. I'd start typing something, realise it was wrong, delete it, and type the right thing. Nobody else needed to know. On the loop, my opinions need to live _somewhere the agent can read_. Otherwise every new session starts by asking me to re-list them, and I end up context-dumping for ten minutes before any code gets touched.

This is fine, I told myself. I'll just have a good CLAUDE.md. And a good CLAUDE.md does a lot of work — probably the single highest-leverage file in any repo I care about. But CLAUDE.md has a specific problem: it's advice. It's convention. It's "please don't do X." The agent reads it, mostly follows it, occasionally forgets it, and there's no machine pulling it back when it drifts.

## Context rot

The phrase I've seen going around is "context rot". Mine looks like this. I explain my opinions clearly in session one. Session one builds a thing. Session two inherits the code session one wrote, re-reads CLAUDE.md, interprets it slightly differently, and builds something adjacent. Session three inherits session two's interpretation plus mine, averages them, and now we've drifted. By session eight, nobody quite remembers what we agreed on.

The thing that kills me is that each session individually was fine. Each session read the docs. Each session made reasonable decisions. It's the accumulation that's off.

This isn't a model problem. Opus 4.7 is extraordinarily good at long, coherent sessions; I don't have a complaint on the capability axis. It's that _memory across sessions is my job_, and I've been doing it with the wrong tool. A markdown file that says "please prefer X" is fine for taste-level preferences. For anything load-bearing, it's too soft.

## The shape of the answer

I think the shape of the answer — I'm more confident about it every week — is that the decisions I care about need to be _in the repo in a form the agent can't accidentally drift away from_. Not "please use Paddle," but a billing package that only exports a Paddle surface. Not "please isolate tenants," but a database policy that makes cross-tenant reads fail. Not "please use the typed contract," but a build that won't compile without it.

Call it enforcement. Call it invariants. It's the same idea: the opinions that matter live in places the agent has to respect, not in paragraphs the agent has to remember.

## Where this is going

I've been building something that tries to encode this. It's boring in all the right ways and sharp in a few specific ones. I'll post about it next week.

Before that, though, one more piece I keep running into: _which_ opinions are worth encoding, and which belong in the docs. There's a difference between a convention and an invariant, and most things aren't invariants. That's next.
