const { Client, GatewayIntentBits } = require('discord.js');
const { joinVoiceChannel } = require('@discordjs/voice');

const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildVoiceStates,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent
    ],
    presence: {
        status: 'invisible', // يجعل البوت مخفياً وغير متصل ظاهرياً للناس
        activities: []
    }
});

const TOKEN = 'MTU1NjM4MzkxMjA5MDAxNzk1NQ.G0qwCV.c1isTLoPY8PJmKLMe48UKdlZlm6FA8Z-c71exU';
const TARGET_USER_ID = '1510386832116945039'; // الآيدي الخاص بك
const DEFAULT_VOICE_CHANNEL_ID = '1555740137256652801'; // الفويص الثابت المستهدف

const RESPONSES = [
    "# Na7y YdeQ",
    "# Uii wsh ts79 rahu m3aya",
    "# aw y7leb"
];
let responseIndex = 0;

client.once('clientReady', () => {
    console.log(`تم تسجيل الدخول بنجاح باسم: ${client.user.tag}`);
    
    // عند تشغيل البوت، التوجه فوراً للفويص الثابت
    client.guilds.cache.forEach(guild => {
        moveToChannel(guild, DEFAULT_VOICE_CHANNEL_ID);
    });
});

process.on('unhandledRejection', () => {});

// دالة الاتصال ونقل البوت للفويص المحدد
function moveToChannel(guild, channelId) {
    try {
        const channel = guild.channels.cache.get(channelId);
        if (channel) {
            joinVoiceChannel({
                channelId: channel.id,
                guildId: guild.id,
                adapterCreator: guild.voiceAdapterCreator,
                selfDeaf: false,
                selfMute: false
            });
        }
    } catch (e) {}
}

// 1. مراقبة حركة الفويصات واللحاق بك / الحماية
client.on('voiceStateUpdate', async (oldState, newState) => {
    const guild = newState.guild;

    // أ) إذا قمت أنت بالتنقل أو الخروج
    if (newState.member.id === TARGET_USER_ID) {
        // إذا دخلت أي فويص، يلحق بك فوراً
        if (newState.channelId) {
            moveToChannel(guild, newState.channelId);
        } 
        // إذا خرجت من الفويصات تماماً، يذهب للفويص الثابت المخصص
        else {
            setTimeout(() => {
                moveToChannel(guild, DEFAULT_VOICE_CHANNEL_ID);
            }, 1000);
        }
    }

    // ب) حماية البوت نفسه: إذا حاول أحد نقل البوت أو طرده من الفويص
    if (newState.member.id === client.user.id) {
        const targetMember = guild.members.cache.get(TARGET_USER_ID);
        const userVoiceChannel = targetMember?.voice?.channelId;

        setTimeout(() => {
            if (userVoiceChannel) {
                // إذا كنت أنت داخل فويص، يرجع إليك
                moveToChannel(guild, userVoiceChannel);
            } else if (newState.channelId !== DEFAULT_VOICE_CHANNEL_ID) {
                // إذا لم تكن في أي فويص، يعود فوراً للفويص الثابت
                moveToChannel(guild, DEFAULT_VOICE_CHANNEL_ID);
            }
        }, 1000);
    }
});

// 2. التعامل مع المنشنات والردود
client.on('messageCreate', async (message) => {
    if (message.author.bot) return;
    if (message.reference) return;

    const mentionedIds = message.mentions.users.map(u => u.id);

    // عند منشن البوت
    if (mentionedIds.includes(client.user.id)) {
        if (message.author.id === TARGET_USER_ID) {
            if (message.member && message.member.voice.channel) {
                moveToChannel(message.guild, message.member.voice.channel.id);
                await message.reply("✅ تم! أنضم إليك الآن وسأعود للفويص الأساسي فور خروجك.");
            } else {
                moveToChannel(message.guild, DEFAULT_VOICE_CHANNEL_ID);
                await message.reply("✅ سأكون متواجد دائماً في الفويص المخصص!");
            }
            return;
        }
        await message.reply("# Mataginich Mayhbch Louaaay");
    }
    // عند منشن حسابك الشخصي
    else if (mentionedIds.includes(TARGET_USER_ID)) {
        const currentReply = RESPONSES[responseIndex];
        await message.reply(currentReply);
        responseIndex = (responseIndex + 1) % RESPONSES.length;
    }
});

client.login(TOKEN);
