---
title: Decided already
date: 2026-03-30
excerpt: YAGNI, DRY, and the refusal to reinvent have been around for decades. They mean something slightly different when you're not the one typing.
---

Last week I wrote about the five taxes that stop me shipping personal projects. The one that kept pulling at me most was the decision tax — the realisation that a blank repo doesn't just cost me a week of plumbing, it costs me a week of re-making calls I've already made two or three times before.

I've been chewing on this one for a while, and I think the answer isn't scaffolding. It's a set of decisions, written down somewhere the next session can actually see them.

## Old principles, new flavour

There's nothing clever here. The three principles I keep coming back to are all old enough to have Wikipedia pages.

**YAGNI.** You aren't gonna need it. If I can defer the admin dashboard, the webhook subscription system, and the OpenAPI spec until a real user demands them, I should. I always say I will. I don't always.

**DRY.** Don't repeat yourself. Usually aimed at code, but the interesting version for me right now is _don't repeat yourself across projects_. If I've already decided that email goes through Resend and jobs go through pg-boss, that shouldn't be a decision I re-make next time. That should be a thing that's just true when I start.

**No to NIH.** Not Invented Here. If a battle-tested library does the job, I want to stop being too proud to use it. I've written my own auth. I've written my own queue. I'm done.

None of these ideas are new. What _is_ new, at least for me, is that I'm now sharing a codebase with something that doesn't remember yesterday. When it's just me, my undocumented opinions are fine — they live in my head, and my head goes with me to the next project. When I'm pairing with an agent, my undocumented opinions are a _cost_. Every new session I have to list them out again. Every time I list them out, I list them slightly differently. The agent does its best with what I've told it in the last ninety seconds.

## Decisions as the thing you carry

So the unit I've started to care about isn't code. It's _decisions_. A decision is: Paddle rather than Stripe, because Merchant of Record means I don't do VAT. A decision is: Postgres with Prisma, because I know the shape of the migrations. A decision is: tenants are isolated at the database, not at a middleware I might one day forget to apply.

The decisions I want to carry between projects aren't code. The code for each is tiny. They're the _reasons_. "Paddle rather than Stripe" without the MoR context is a preference. With the context, it's a judgement that holds up to questioning.

A boilerplate gives you the code and throws away the reasons. That's fine if you already know them. It's a disaster if you don't, because then you inherit a stack of opinions you can't defend.

## The tax I'm actually paying

If I look back at those five taxes from last week, the decision tax is the one underneath all of them. Auth, infra, scope — they're all easier once the decisions are pre-made. The weekly grind isn't "I don't know how to set up Postgres." It's "I don't know whether this project deserves Postgres yet, or if I should just use SQLite, or whether the fact that I'm even asking this means I'm procrastinating."

That's the tax. It's not technical. It's the cognitive cost of being allowed to re-open a decision.

## What I actually want

A thing I can clone. Where the decisions are already made _and_ written down. Where the reasons are somewhere I can point at them when a fresh agent session asks "why Paddle?" Where if I decide I disagree with a decision, I know what to rip out and what not to rip out, because the dependencies are legible.

I've been building one. I'll talk about it soon. First, though, I want to talk about the thing that kept forcing the issue: working _on_ the loop rather than _in_ it.
