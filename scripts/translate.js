const OPENAI_BASE_URL = process.env['OPENAI_BASE_URL'] ?? 'https://api.openai.com/v1';
const OPENAI_API_KEY = process.env['OPENAI_API_KEY'];
const OPENAI_MODEL = process.env['OPENAI_MODEL'] ?? 'gpt-5-mini';

const TARGET_LANGUAGE = process.env['TARGET_LANGUAGE'];
const TARGET_LANGUAGE_NAME = process.env['TARGET_LANGUAGE_NAME'];

const fs = require('fs');

function getLocalization(languageKey) {
    return JSON.parse(fs.readFileSync(`assets/l10n/intl_${languageKey}.arb`, 'utf-8'));
}

const humanMadeLocalizations = ['en', 'ru']; // we'll pass multiple localizations to model for better context

var targetLocalization = getLocalization(TARGET_LANGUAGE);

const locale = getLocalization(humanMadeLocalizations[0]);
var keys = Object.keys(locale).filter(x => !x.startsWith('@'));

async function batchTranslate(amount) {
    const k = keys.slice(0, amount);

    var modelInput = '';

    for (const localeCode of humanMadeLocalizations) {
        const locale = getLocalization(localeCode);
        modelInput = `Translation file intl_${localeCode}.arb:\n\`\`\`json\n${JSON.stringify(Object.fromEntries(Object.entries(locale).filter(x => k.includes(x[0]) || k.includes(`@${x[0]}`))), false, '\t')}\n\`\`\`\n---\n`;
    }

    modelInput = modelInput.trim();

    const response = await fetch(`${OPENAI_BASE_URL}/chat/completions`, {
        headers: {
            'Authorization': `Bearer ${OPENAI_API_KEY}`,
            'Content-Type': 'application/json'
        },
        method: 'POST',
        body: JSON.stringify({
            model: OPENAI_MODEL,
            messages: [
                {
                    role: 'system',
                    content: `You are a professional linguist, specialized in translating User Interfaces.

You will be provided a JSON list of ${k.length} string keys. Each key has ${humanMadeLocalizations.length} values in different languages.
Based on provided translations, you need to translate each string into ${TARGET_LANGUAGE_NAME ?? `language, which two-letter code is ${TARGET_LANGUAGE}`}.

Your output is expected to be a JSON object, which has exactly the same keys as input JSON object. Wrap your JSON output in Markdown codeblock.`
                },
                {
                    role: 'user',
                    content: modelInput
                }
            ]
        })
    });

    if (!response.ok) {
        console.error(`Failed to request chat completions (${response.status} ${response.statusText}): ${await response.text()}`);
        return;
    }

    const jsonResponse = await response.json();
    const textResponse = jsonResponse.choices?.[0]?.message?.content;

    if (typeof textResponse !== 'string') {
        return console.error('content is not string');
    }

    console.log(textResponse);
    console.log(`[Token usage] prompt: ${jsonResponse.usage.prompt_tokens} | completion: ${jsonResponse.usage.completion_tokens} | total: ${jsonResponse.usage.total_tokens}`);

    const re = /```(json)?\n((.|\n)+)\n```/gm;
    const matches = Array.from(textResponse.matchAll(re));

    const translationResponse = matches[0][2];

    const translation = JSON.parse(translationResponse);

    targetLocalization = {
        ...targetLocalization,
        ...translation
    };

    keys = keys.slice(amount);
}

const targetLen = Object.keys(getLocalization(humanMadeLocalizations[0])).length;

async function translationLoop() {
    if (Object.keys(targetLocalization).length == targetLen) {
        console.log('Done');
        process.exit(0);
    }
    console.log(`Sending batch request...`);
    await batchTranslate(128);
    targetLocalization['@@locale'] = TARGET_LANGUAGE;
    targetLocalization['@@last_modified'] = new Date().toISOString();
    fs.writeFileSync(`assets/l10n/intl_${TARGET_LANGUAGE}.arb`, JSON.stringify(targetLocalization, false, '\t'));
    console.log(`${Object.keys(targetLocalization).length} out of ${targetLen} keys translated.`);
    setTimeout(() => {
        translationLoop();
    }, 3000);
} 32

translationLoop();