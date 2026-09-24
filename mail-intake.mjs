import { readFileSync, writeFileSync, mkdirSync, existsSync, appendFileSync } from "node:fs";

const BASE = process.env.PYTHIA_SANDBOX || "http://127.0.0.1:18960";
const STATE = process.env.PYTHIA_MAIL_STATE || "/var/lib/pythia-school/replied-uids.json";
const LESSONS = process.env.PYTHIA_SCHOOL_LESSONS || "/var/lib/pythia-school/lessons.jsonl";
const REASON = process.env.PYTHIA_REASONING_URL || "http://127.0.0.1:11437";
const MODEL = process.env.PYTHIA_REASONING_MODEL || "mistral-nemo:12b";
const mode = process.argv[2] || "run";
const POISON = /трак|стоянк|драйвер|главный фокус из этого письма|живой приём денег|^\s*принято\.?\s*$/i;
const PRICE_CARD = /\$11|\$4\.99|полный разбор ситуации и два уточняющ/i;
const SITES = ["okpythia.com", "bimboprotocol.com", "redgrimoire.com", "theantigloss.com"];
const HOME = [...SITES, "books2read.com"];
const FETCH_MS = 12000;
const TEXT_CAP = 24000;
const UA = "PythiaSchool/009 (+https://okpythia.com)";
