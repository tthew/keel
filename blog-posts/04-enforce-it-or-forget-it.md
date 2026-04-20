---
title: Enforce it or forget it
date: 2026-04-13
excerpt: Conventions are negotiable. Invariants aren't. The difference matters more than it sounds, especially once an agent is the one making the calls.
---

Last post I said the decisions I care about need to live somewhere the agent can't drift away from. The follow-up question is: _which_ decisions?

Because not every opinion deserves that treatment. Most of them don't. Most of them are taste, or convention, or "we prefer this style in this codebase", and if you hardwire those you end up with a cage instead of a substrate.

So the question is: where's the line? I think there's a useful distinction, which I've been calling conventions versus invariants.

## Conventions

A convention is something you'd like to be true, usually. It's the stuff that lives comfortably in a style guide or a CLAUDE.md. "We use single quotes in TypeScript." "Prefer composition over inheritance." "Keep functions under 40 lines unless you have a good reason."

Conventions are negotiable on purpose. Sometimes the 40-line function is the right call. Sometimes the single quote is inside a JSON fixture and has to be a double quote. You want your tools to hold the convention gently, remind you when you drift, and let you push back when you've got a reason.

A lot of agent-assisted code is this, and it's fine. An agent that follows your conventions most of the time is a good agent. The only thing you need is a reminder, usually a linter, usually a line in a rule file.

## Invariants

An invariant is something that is _not_ negotiable. If it isn't true, something load-bearing breaks. If it drifts, you won't notice until a paying customer does.

The ones that bite me most:

- **Tenant isolation.** If a query in a B2B app can return another tenant's data, you don't have an isolation bug, you have a lawsuit. Reviewing every query by eye doesn't scale. A middleware you can forget to apply isn't isolation. A database policy that refuses the query is.

- **Import boundaries.** If the billing package imports directly from the auth package's internals, and the next refactor moves those internals, you get a pile of broken edges that "used to work". A linter that asks nicely is not enough. A compile that fails is.

- **The quality gate itself.** Type-check, lint, test, security scan. If any of these can be turned off to unblock a commit, they _will_ be turned off to unblock a commit. Ask me how I know.

What these have in common is that "please be careful" isn't an answer. The cost of getting them wrong is much higher than the cost of the machinery that makes them impossible to get wrong. The right tool is a gate, not a suggestion.

## Toggled off

There's a rule of thumb I keep coming back to. It isn't mine, but I've heard it enough times that I've internalised it: _discipline that can be toggled off is discipline that will be toggled off._ Usually at three in the morning, usually before a demo, usually by me.

This isn't a moral failing. It's how humans and agents both behave under pressure. If there's a quick way to bypass a check, someone will take the quick way, because the check is an obstacle and the demo is a goal. The right move isn't to trust yourself more. It's to put the thing you can't afford to skip somewhere that _doesn't have a toggle_.

For agents specifically, this is more acute. An agent doesn't know which rule is load-bearing and which is stylistic, so if you tell it "the tests must pass", it'll mostly make the tests pass, but if the tests are flaky it'll sometimes skip them to finish the task. Putting "tests must pass" into CI as a blocking merge check removes the question entirely.

## Very few invariants

One last thing, because this can go wrong in the other direction. The whole point of having a distinction between conventions and invariants is that _almost everything is a convention_. Invariants should be rare, load-bearing, and paid for. Every invariant is a thing you've decided you can't live without, and every invariant takes effort to encode and keep true.

When I've counted mine up, there are about seven. Tenant isolation, import boundaries, the gate stack, a couple of data-contract ones, a rule about how secrets leave the environment. Everything else is convention, taste, or preference.

Seven is not a lot. That's the point. If you've got seventy, you haven't made any decisions, you've built a cage.

## Putting it together

So: conventions in a CLAUDE.md, held gently. Invariants in the repo, enforced at the layer where "please don't" isn't a defence. A very small number of invariants, because they're expensive.

I've been assembling all of this — the decisions, the enforcement, the substrate underneath — into a thing I can clone when I start a new project. It's nearly ready. Next post introduces it properly.
