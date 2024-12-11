import { getLogger, IPPAgentPlugin } from "ppagent";

const logger = getLogger("sample-plugin");
// eslint-disable-next-line @typescript-eslint/no-unused-vars
const plugin: IPPAgentPlugin = (app) => {
    return {
        name: "sample-plugin",
        desc: "一个示例插件",
        needOnline: false,
        init: async () => {
            logger.info("sample plugin init");
            return {};
        },
        dispose: async () => undefined,
    };
};

// 务必使用default，否则不支持通过在线配置的方式加载
export default plugin;
