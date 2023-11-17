import { PrismaClient} from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
        console.log('Main...');
        const user = await prisma.user.create({
            data: {
                name: 'Lucas',
                email: 'lucas@teste'
            }
        });
        console.log(user);
}
main()
   .then(async () => {
    await prisma.$disconnect();
   })
   .catch(async e => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
   });