import type { Metadata } from "next";
import "./globals.css";
export const metadata: Metadata = { title: "Weiren Thrifts — Good clothes. Second lives.", description: "One-of-a-kind pre-loved finds. Better stories. A different kind of wardrobe.", robots: { index: false, follow: false } };
export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) { return <html lang="en" suppressHydrationWarning><body>{children}</body></html>; }
