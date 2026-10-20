"use client";
import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase";
import { ArrowLeft, LockKeyhole } from "lucide-react";

export default function AccountPage(){
 const router=useRouter();
 const [mode,setMode]=useState<"login"|"signup"|"reset">("login");
 const [email,setEmail]=useState("");
 const [password,setPassword]=useState("");
 const [name,setName]=useState("");
 const [busy,setBusy]=useState(false);
 const [message,setMessage]=useState("");
 const supabase=createClient();
 useEffect(()=>{if(!supabase)return;supabase.auth.getUser().then(({data})=>{if(data.user)router.replace("/account/dashboard")})},[]);
 async function submit(e:React.FormEvent){e.preventDefault();setMessage("");if(!supabase){setMessage("Authentication is not configured yet. Add the Supabase URL and publishable key to your local environment and Vercel settings.");return}setBusy(true);try{if(mode==="signup"){const {error}=await supabase.auth.signUp({email,password,options:{data:{full_name:name},emailRedirectTo:window.location.origin+"/account"}});if(error)throw error;setMessage("Check your inbox for a verification email if email confirmation is enabled.")}else if(mode==="reset"){const {error}=await supabase.auth.resetPasswordForEmail(email,{redirectTo:window.location.origin+"/account/reset"});if(error)throw error;setMessage("If an account exists for this email, password reset instructions have been sent.")}else{const {error}=await supabase.auth.signInWithPassword({email,password});if(error)throw error;router.push("/account/dashboard");router.refresh()}}catch(err){setMessage(err instanceof Error?err.message:"Something went wrong. Please try again.")}finally{setBusy(false)}}
 return <main className="auth-page"><a className="auth-back" href="/"><ArrowLeft size={16}/> BACK TO THE ARCHIVE</a><div className="auth-card"><div className="auth-monogram">WT</div><div className="eyebrow">THE WEIREN ACCOUNT</div><h1>{mode==="signup"?"Make it yours.":mode==="reset"?"Back into your account.":"Good to see you."}</h1><p>{mode==="signup"?"Save the pieces you love and keep your orders in one place.":mode==="reset"?"We'll send instructions to the email address on your account.":"Sign in to see your saved finds and order history."}</p><form onSubmit={submit}>{mode==="signup"&&<label>Your name<input autoComplete="name" value={name} onChange={e=>setName(e.target.value)} required/></label>}<label>Email address<input type="email" autoComplete="email" value={email} onChange={e=>setEmail(e.target.value)} required/></label>{mode!=="reset"&&<label>Password<input type="password" autoComplete={mode==="signup"?"new-password":"current-password"} minLength={8} value={password} onChange={e=>setPassword(e.target.value)} required/></label>}<button className="btn btn-dark auth-submit" disabled={busy}>{busy?"PLEASE WAIT…":mode==="signup"?"CREATE ACCOUNT":mode==="reset"?"SEND RESET LINK":"SIGN IN"} <LockKeyhole size={15}/></button></form>{message&&<p className="auth-message" role="status">{message}</p>}<div className="auth-links">{mode==="login"&&<button onClick={()=>setMode("reset")}>Forgot password?</button>}<button onClick={()=>{setMessage("");setMode(mode==="signup"?"login":"signup")}}>{mode==="signup"?"Already have an account? Sign in":"New here? Create an account"}</button>{mode==="reset"&&<button onClick={()=>setMode("login")}>Back to sign in</button>}</div><small>Account features require a configured Supabase project. We never store your password ourselves.</small></div></main>
}
