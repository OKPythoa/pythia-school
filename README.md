# pythia-school

One Intelligence loop for education mail:
letter → knowledge_retrieve → facts from THIS letter → one mail_reply → knowledge_propose.

$11 / product card is used ONLY when the letter asks price of our sites.
Focus / Gate / Education letters are answered from their own facts, never from the till template.

## Deploy on lv184 only

This does not install Protocol, voice, GPU, or Lab.

```
curl -fsSL https://raw.githubusercontent.com/OKPythoa/pythia-school/main/install.sh | bash
```

Then once, if old UIDs must stay unanswered:

```
node /opt/pythia-school/mail-intake.mjs seed
```
