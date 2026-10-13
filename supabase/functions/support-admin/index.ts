// Support staff accounts, administered by developers only. Creating a
// sign-in account, resetting its password and blocking it need the
// service-role key, which exists only here on the server — never in the app.
import { createClient } from "jsr:@supabase/supabase-js@2";

const url = Deno.env.get("SUPABASE_URL")!;
const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

function reply(status: number, body: unknown) {
  return new Response(JSON.stringify(body), { status, headers: { ...cors, "Content-Type": "application/json" } });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return reply(405, { error: "method" });

  // Who is calling: their own session, checked against developer_admins.
  const caller = createClient(url, anonKey, {
    global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } },
  });
  const { data: isDev, error: devErr } = await caller.rpc("is_developer_admin");
  if (devErr || isDev !== true) return reply(403, { error: "developer only" });

  const admin = createClient(url, serviceKey, { auth: { persistSession: false } });
  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return reply(400, { error: "bad request" });
  }
  const action = body.action as string;

  if (action === "create") {
    const email = String(body.email ?? "").trim().toLowerCase();
    const password = String(body.password ?? "");
    const fullName = String(body.full_name ?? "").trim();
    if (!email.includes("@") || password.length < 8 || fullName.length === 0) {
      return reply(400, { error: "invalid input" });
    }
    const { data: created, error } = await admin.auth.admin.createUser({ email, password, email_confirm: true });
    if (error || !created.user) return reply(409, { error: error?.message ?? "could not create account" });
    // Inserted with the caller's session so the audit trail names them.
    const { data: agent, error: insErr } = await caller.from("support_agents").insert({
      auth_user_id: created.user.id,
      full_name: fullName,
      email,
      phone: String(body.phone ?? ""),
      address: String(body.address ?? ""),
      job_title: String(body.job_title ?? ""),
      salary_minor_units: Number(body.salary_minor_units ?? 0),
      notes: String(body.notes ?? ""),
    }).select().single();
    if (insErr) {
      await admin.auth.admin.deleteUser(created.user.id);
      return reply(409, { error: insErr.message });
    }
    return reply(200, { agent });
  }

  const agentId = String(body.agent_id ?? "");
  const { data: agent } = await caller.from("support_agents").select().eq("id", agentId).maybeSingle();
  if (!agent) return reply(404, { error: "agent not found" });

  if (action === "reset_password") {
    const password = String(body.password ?? "");
    if (password.length < 8) return reply(400, { error: "password too short" });
    if (!agent.auth_user_id) return reply(409, { error: "no sign-in account" });
    const { error } = await admin.auth.admin.updateUserById(agent.auth_user_id, { password });
    if (error) return reply(409, { error: error.message });
    await caller.from("platform_audit_logs").insert({
      action: "support_agent.reset_password",
      details_json: JSON.stringify({ agent_id: agentId }),
    });
    return reply(200, { ok: true });
  }

  if (action === "set_status") {
    const status = String(body.status ?? "");
    if (!["active", "suspended", "terminated"].includes(status)) return reply(400, { error: "invalid status" });
    // Suspended or terminated accounts can't sign in; history stays.
    if (agent.auth_user_id) {
      const { error } = await admin.auth.admin.updateUserById(agent.auth_user_id, {
        ban_duration: status === "active" ? "none" : "876000h",
      });
      if (error) return reply(409, { error: error.message });
    }
    const { error: updErr } = await caller.from("support_agents").update({
      employment_status: status,
      presence: status === "active" ? agent.presence : "signed_out",
    }).eq("id", agentId);
    if (updErr) return reply(409, { error: updErr.message });
    return reply(200, { ok: true });
  }

  return reply(400, { error: "unknown action" });
});
