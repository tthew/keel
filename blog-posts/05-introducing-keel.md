---
title: Introducing Keel
date: 2026-04-20
excerpt: Four posts in, the reveal. An opinionated SaaS substrate built for one person who wants to stop re-making the same decisions and let the agents get on with it.
---

Four posts. One for each warm-up. I owe you the thing itself.

It's called _Keel_.

A keel is the bit of a ship that sits under the waterline and stops it capsizing. You don't see it. You don't talk about it. You notice it very sharply when it isn't there. That's roughly the energy I wanted for this.

## What it is

Keel is a SaaS repo with the boring layer already finished. The stack, the auth, the billing, the tenant isolation, the jobs, the observability. You clone it, spec your idea with BMad, turn Ralph loose, and ship.

The bet is everything I've been writing about for the last month. Most of the drag on agentic personal projects is the stuff _around_ the agent, not the agent itself. A blank repo means auth, infra, context, scope, and decision taxes all hit you in the first week. By the time you've paid them, the energy's gone. If the decisions are pre-made and pre-enforced, you start the project on a different footing.

The stack, briefly, because none of this is the interesting part: TypeScript, TanStack Start on Vite, Postgres with Prisma, tRPC for the typed contracts, better-auth for sessions, Paddle for billing, pg-boss for jobs, Resend for email. Nothing invented here. What's new is that it's all decided together, the reasons are in the repo, and the things that have to be true — tenant isolation, import boundaries, the gate stack — are enforced where they can't be toggled off.

There's a CI check that clones the repo fresh, signs up a user, creates a team, and completes a paid Paddle sandbox subscription. If that check fails, the repo is broken. That's the floor.

## Who it's for

Me. That's it. I'm using _n=1_ honestly here. Keel is built for one person, who happens to be me, because I got tired of watching myself not ship things.

If you recognise yourself in the posts leading up to this one — if you've been paying those five taxes too, if your context rots across sessions, if you've got a `projects/` folder you'd rather not look inside — you're welcome to clone it. MIT licence, fork freely, take what you want, rip out the rest. The unstub guides in `docs/unstub/` are there for exactly that, and they run in CI quarterly so they don't go stale.

But I'm not building a community product. I'm not running a Discord. I'm not going to adapt it to your stack choices. If you need something to adapt to you, that's what Makerkit and ShipFast are for, and they're quite good at it.

## How it fits with the other pieces

Four things I'm running together:

- **BMad** handles the planning. PRD, epics, stories, as enforceable contracts between phases.
- **Ralph** runs the loop. One story per iteration, commit, exit.
- **Claude Code** does the typing.
- **Keel** is what they all execute against.

Any one of these works on its own. I've used BMad without Ralph, Ralph without Keel, Claude Code against plenty of other repos. The combination is where it gets interesting for me, because each piece sharpens the others. A plan is easier to hand to a loop when the substrate is predictable. A loop is cheaper to run when the decisions are already frozen. An agent is more useful when it doesn't have to re-ask what you want.

## What's next

The next posts go deeper. The shape of the invariant layer, and why RLS at the database is the hill I've picked. How the CI pyramid is decomposed, and why a single 60-minute gate is a trap. What Ralph does when a task misbehaves, and why I called the halt sentinel what I did. The monthly experiment I'm running to check whether Keel is still earning its keep, or whether the frontier models have absorbed it.

For now, though, the repo is on GitHub, the first version is tagged, and the CI is green. I'd rather it were small and honest than big and impressive. That seems to be a pattern with me lately.

More soon.
