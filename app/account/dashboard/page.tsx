"use client";
import "../auth.css";
import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase";
import { ArrowLeft, LogOut, Package, UserRound } from "lucide-react";

export default function AccountDashboard(){
 const router=useRouter();const [email,setEmail]=useState("");const [orders,setOrders]=useState<{id:string;order_number:string;status:string;total_paise:number;created_at:string}[]>([]);const [message,setMessage]=useState("Loading your account…");
 useEffect(()=>{const supabase=createClient();if(!supabase){setMessage("Supabase is not configured. Set environment variables to use accounts.");return}supabase.auth.getUser().then(async({data,error})=>{if(error||!data.user){router.replace("/account");return}setEmail(data.user.email||"");const result=await supabase.from("orders").select("id,order_number,status,total_paise,created_at").order("created_at",{ascending:false});if(result.error)setMessage("Order history will appear after the store database is configured.");else{setOrders(result.data||[]);setMessage("")}})},[]);
 async function logout(){const supabase=createClient();if(supabase)await supabase.auth.signOut();router.replace("/");router.refresh()}
 return <main className="auth-page"><a className="auth-back" href="/"><ArrowLeft size={16}/> BACK TO THE ARCHIVE</a><div className="account-panel"><div className="eyebrow">YOUR WEIREN ACCOUNT</div><h1>Your archive.</h1><p className="account-email"><UserRound size={16}/>{email||"Customer account"}</p><div className="account-section-title"><Package size={18}/><h2>Order history</h2></div>{message&&<p className="auth-message">{message}</p>}{!message&&!orders.length&&<div className="account-empty"><p>No orders yet. Your next favourite piece is out there.</p><a className="btn btn-dark" href="/#shop">EXPLORE THE FINDS</a></div>}{orders.map(order=><article className="order-row" key={order.id}><div><strong>{order.order_number}</strong><span>{new Date(order.created_at).toLocaleDateString("en-IN",{day:"numeric",month:"short",year:"numeric"})}</span></div><div><strong>{new Intl.NumberFormat("en-IN",{style:"currency",currency:"INR",maximumFractionDigits:0}).format(order.total_paise/100)}</strong><span>{order.status.toUpperCase()}</span></div></article>)}<button className="btn btn-outline account-logout" onClick={logout}><LogOut size={15}/> SIGN OUT</button></div></main>
}
