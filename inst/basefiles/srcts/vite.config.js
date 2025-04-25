import { defineConfig } from 'vite'
import { resolve } from 'path'
import wasm from "vite-plugin-wasm";

export default defineConfig({
  build: {
    target: 'esnext',
    emptyOutDir: false,
    outDir: '../inst/dist',
    lib : {
      formats: ['es'],
      // Could also be a dictionary or array of multiple entry points
      entry : resolve (__dirname , 'src/index.ts'),
      name : '@@package_name@@',
      fileName : '@@package_name@@',
    },
  },
  plugins: [
    wasm()
  ]
})

