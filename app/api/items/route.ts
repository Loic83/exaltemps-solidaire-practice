import { NextResponse } from "next/server";
import { getItems } from "@/lib/data";

export async function GET() {
  return NextResponse.json(getItems());
}
